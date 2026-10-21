/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

/// Json tests interface
#include "../json"

namespace meta_api
{
namespace json
{
final class Expect
{
    string title;
    bool Failed;

    /**
    *   @brief Create and record the result of one JSON test.
    *   @param title The test name shown in the result log.
    *   @param expected The Boolean result the test is expected to produce.
    *   @param condition The actual Boolean result being checked.
    **/
    Expect( string title, bool expected, bool condition )
    {
        this.title = title;

        if( condition != expected )
        {
            Failed = true;
            g_Game.AlertMessage( at_error, GetLogPrefix( int( tests::__TestingVersion__ ) ) + "FAIL: %1\n", title );
        }
        else
        {
            g_Game.AlertMessage( at_notice, GetLogPrefix( int( tests::__TestingVersion__ ) ) + "PASS: %1\n", title );
        }

        tests::__Results__.insertLast(this);
    }
}

// Implement the interface and call meta_api::json::tests::Register(this); to register your implementation.
interface ITest
{
    /// Json version
    const Version GetVersion();
    /**
        If any data of the following object is missing from your deserialization then assume the test failed and return false.
{
    "null": null,
    "integer": 1,
    "float": 1.5,
    "bool": true,
    "string": "string",
    "object":
    {
    },
    "array":
    [
        null,
        1,
        1.5,
        true,
        false,
        "string",
        {},
        []
    ]
}
    */
    /// @param serialized JSON input containing the values the implementation is expected to support.
    bool DeserializeAllTypes( const string&in serialized );
    // serialized could be anything invalid, this method is called for all the invalidation tests and should only return the object deserialization result
    /// @param serialized JSON input to pass through the implementation's generic deserializer.
    bool DeserializeGeneric( const string&in serialized );
    // For your own tests initialize an Expect class passing up a title, the expected result and the conditional that should be equal to the expected
    void AdditionalTests();
}

namespace tests
{
uint __AllTestsTotal__ = 0;
uint __AllTestsPassed__ = 0;
uint __AllTestsFailed__ = 0;
uint __AllTests__ = 0;
Version __TestingVersion__ = Version::Latest;

array<ITest@> __Tests__(0);

// Register a test class
/**
*   @brief Register a JSON test implementation.
*   @param test The test implementation to add to the registry.
**/
void Register( ITest@ test )
{
if( test is null )
{
    g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::Latest ) ) + "Null test passed on meta_api::json::tests::Register( ITest@ )\n" );
    return;
}
__Tests__.insertLast( test );
} // void Register

array<Expect@> __Results__(0);

/**
*   @brief Run the shared JSON test suite for one implementation.
*   @param test The test implementation to exercise.
*   @param metamod Indicates whether the run is labeled as a Metamod run.
**/
void __RunTests__( ITest@ test, bool metamod )
{
__AllTests__++;
__Results__.resize(0);
__TestingVersion__ = test.GetVersion();
g_Game.AlertMessage( at_notice, GetLogPrefix( int( __TestingVersion__ ) ) + "===== Running json tests for %1 =====\n", ( metamod ? "METAMOD" : "VANILLA" ) );

Expect( "Deserialization and types", true, test.DeserializeAllTypes( "{\"null\": null,\"integer\": 1,\"float\": 1.5,\"bool\": true,\"string\": \"string\",\"object\":{},\"array\":[null,1,1.5,true,false,\"string\",{},[]]}" ) );
Expect( "Single line comments", true, test.DeserializeGeneric( "// Comment before object\n{// Comment after token in object\n\"first\": 1, // Comment after comma\n\"second\": [\n1, // Comment inside array after value with comma\n2 // Comment inside array after value with no comma\n],\n\"third\": 2 // Comment after value with no comma\n}// Comment at end of object" ) );
Expect( "Multi line comments", true, test.DeserializeGeneric( "/**/{\n/*\n*/\n\"first\": 1,/**/\n\"second\":/**/[\n1,/**/\n2\n]/*?*/,\n\"third\"/*x[.*/: 2/**/}\n/**/" ) );
Expect( "Valid literals", true, test.DeserializeGeneric( "[true,false,null,\"\"]" ) );
Expect( "Valid literals", true, test.DeserializeGeneric( "[true,false,null,\"\"]" ) );
Expect( "Invalid pairs with no coma separator", false, test.DeserializeGeneric( "{\"0\":0\n\"1\":1}" ) );
Expect( "Invalid literal", false, test.DeserializeGeneric( "{\"value\":tru}" ) || test.DeserializeGeneric( "[tru]" ) );
Expect( "Invalid missing coma in array", false, test.DeserializeGeneric( "[1 2]" ) || test.DeserializeGeneric( "[1\t2]" ) || test.DeserializeGeneric( "[1\n2]" ) );
Expect( "Invalid root data outside of object", false, test.DeserializeGeneric( "{} something" ) );
Expect( "Invalid object exit token", false, test.DeserializeGeneric( "{]" ) );
Expect( "Invalid array exit token", false, test.DeserializeGeneric( "[}" ) );
Expect( "Invalid unterminated object", false, test.DeserializeGeneric( "[" ) || test.DeserializeGeneric( "{" ) );
Expect( "Valid empty main array/object", true, test.DeserializeGeneric( "[]" ) && test.DeserializeGeneric( "{}" ) );
// This seemed to be valid in metamod maybe we're missing some option there.
Expect( "Invalid trailing comma in object/array", false, test.DeserializeGeneric( "{\"1\":1,}" ) || test.DeserializeGeneric( "[1,]" ) );
Expect( "Unterminated string", false, test.DeserializeGeneric( "{\"a\":\"test}" ) );
Expect( "Weird whitespace", true, test.DeserializeGeneric( "{\n\t \"a\" : \r\n 1 \t }" ) );
Expect( "Non-string key", false, test.DeserializeGeneric( "{1: \"a\"}" ) );
Expect( "Missing colon", false, test.DeserializeGeneric( "{\"a\" 1}" ) );
Expect( "Trailing object/array", false, test.DeserializeGeneric( "{}{}" ) || test.DeserializeGeneric( "[][]" ) );
Expect( "Trailing whitespace OK", true, test.DeserializeGeneric( "{}   \n\t" ) );
Expect( "Empty input", false, test.DeserializeGeneric( "" ) );
Expect( "Only whitespace", false, test.DeserializeGeneric( "   \n\t" ) );
Expect( "garbage root", false, test.DeserializeGeneric( "some garbage not a json" ) );
Expect( "Duplicate keys", false, test.DeserializeGeneric( "{\"a\":1,\"a\":2}") );
Expect( "Escaped quotes", true, test.DeserializeGeneric( "[\"\\\"\"]" ) );
Expect( "Escaped line break", true, test.DeserializeGeneric( "[\"line\\nbreak\"]" ) );
Expect( "Escaped tab", true, test.DeserializeGeneric( "[\"\\ttab\"]" ) );
Expect( "Escaped back slash", true, test.DeserializeGeneric( "[\"\\\\slash\"]" ) );
Expect( "Escaped slash", true, test.DeserializeGeneric( "[\"\\/\"]" ) );
Expect( "Escaped back space", true, test.DeserializeGeneric( "[\"\\b\"]" ) );
Expect( "Escaped form feed", true, test.DeserializeGeneric( "[\"\\f\"]" ) );
Expect( "Escaped Unicode automatically for limitations", true, test.DeserializeGeneric( "{\"a\":\"\\u0041\"}" ) ); // 'A'
Expect( "Invalid escape", false, test.DeserializeGeneric( "{\"a\":\"\\x\"}" ) );
Expect( "UTF-8 BOM", true, test.DeserializeGeneric( "\xEF\xBB\xBF[]" ) );
Expect( "Deep array nesting", true, test.DeserializeGeneric( "[1,[2,[3,[[{\"epic\":true},5],4]]]]" ) );
Expect( "Deep nesting", true, test.DeserializeGeneric( "[{\"1\":[{\"2\":[{\"3\":[null]}]}]}]" ) );
test.AdditionalTests();
// Gather results
uint length = __Results__.length();
array<Expect@> fails(0);
array<Expect@> pass(0);
for( uint ui = 0; ui < length; ui++ )
{
    auto result = __Results__[ui];
    if( result.Failed )
    {
        __AllTestsFailed__++;
        fails.insertLast(result);
    }
    else
    {
        __AllTestsPassed__++;
        pass.insertLast(result);
    }
    __AllTestsTotal__++;
}
if( fails.length() == 0 )
{
    g_Game.AlertMessage( at_notice, GetLogPrefix( int( __TestingVersion__ ) ) + "===== All %1 tests passed =====\n", pass.length() );
}
else if( pass.length() == 0 )
{
    g_Game.AlertMessage( at_error, GetLogPrefix( int( __TestingVersion__ ) ) + "===== All %1 tests failed =====\n", fails.length() );
}
else
{
    g_Game.AlertMessage( at_notice, GetLogPrefix( int( __TestingVersion__ ) ) + "===== Passed: %1 =====\n", pass.length() );
    g_Game.AlertMessage( at_error, GetLogPrefix( int( __TestingVersion__ ) ) + "===== Failed: %1 =====\n", fails.length() );
}

g_Game.AlertMessage( at_notice, GetLogPrefix( int( __TestingVersion__ ) ) + "===== All done! =====\n==================\n" );
__Results__.resize(0);
}

/**
*   @brief Run tests for one registered implementation.
*   @param test The test implementation to run.
**/
void Start( ITest@ test )
{
if( test is null ) {
    g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::Latest ) ) + "Null test passed on meta_api::json::tests::Start( ITest@ )\n" );
    return;
}
/*
bool __META_INSTALLED__ = false;
#if METAMOD_PLUGIN_ASLP
__RunTests__( test, true );
__META_INSTALLED__ = true;
#endif
if( !__META_INSTALLED__ ) {
    g_Game.AlertMessage( at_notice, GetLogPrefix( int( test.GetVersion() ) ) + "===== Skiping json tests for METAMOD as is not installed =====\n" );
}
*/
// If metamod is installed disable the support momentarly to test vanilla behaviour
#if METAMOD_PLUGIN_ASLP
meta_api::json::__METAMOD__ = false;
#endif
__RunTests__( test, false );
#if METAMOD_PLUGIN_ASLP
meta_api::json::__METAMOD__ = true;
#endif
} // void Start

void StartAll()
{
for( uint ui = 0; ui < __Tests__.length(); ui++ )
{
    auto ptr = __Tests__[ui];

    if( ptr !is null )
    {
        Start( ptr );
    }
}
g_Game.AlertMessage( at_notice, GetLogPrefix( int( Version::Latest ) ) + """
========== TEST SUMMARY ==========
Runs: %1
Pass: %2 (%3%%)
Fail: %4 (%5%%)
All : %6
=================================\n""",
__AllTests__,
__AllTestsPassed__, ( __AllTestsTotal__ > 0 ? int( 100.0f * __AllTestsPassed__ / __AllTestsTotal__ ) : 0 ),
__AllTestsFailed__, ( __AllTestsTotal__ > 0 ? int( 100.0f * __AllTestsFailed__ / __AllTestsTotal__ ) : 0 ),
__AllTestsTotal__
);
} // void StartAll

/**
*   @brief Run tests for the registered implementation of a JSON version.
*   @param version The JSON API version whose implementation should be tested.
**/
void Start( const Version&in version )
{
for( uint ui = 0; ui < __Tests__.length(); ui++ )
{
    auto ptr = __Tests__[ui];

    if( ptr !is null && ptr.GetVersion() == version )
    {
        Start( ptr );
        return;
    }
}
g_Game.AlertMessage( at_error, GetLogPrefix( int( version ) ) + "Couldn't find a registered test interface for version %1\n", version );
} // void Start
} // namespace tests
} // namespace json
} // namespace meta_api

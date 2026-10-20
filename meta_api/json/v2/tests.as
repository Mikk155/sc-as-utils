/// Run tests for json
#include "../v2"
#include "schema"
#include "fmt/core"
#include "../tests"

namespace meta_api
{
    namespace json
    {
        namespace v2
        {
            class Test : meta_api::json::ITest
            {
                Test()
                {
                    meta_api::json::tests::Register(this);
                }

                const Version GetVersion() override
                {
                    return Version::V2;
                }

                private Logger m_Logger( "JSON V2" );

                const Logger@ get_Logger() const
                {
                    return this.m_Logger;
                }

                /// @param serialized JSON text or a JSON filename to pass to the generic deserializer.
                bool DeserializeGeneric( const string&in serialized ) override
                {
                    json@ obj;
                    return Deserialize( serialized, obj );
                }

                /// @param serialized JSON text or a JSON filename containing the supported value types.
                bool DeserializeAllTypes( const string&in serialized ) override
                {
                    json@ obj;
                    return Deserialize( serialized, obj );
                }

                void AdditionalTests() override
                {
                    json@ obj;

                    array<string> arr;
                    Expect( "fmt::ToArray conversion", true,
                        Deserialize( "{\"some_array\":[\"string\"]}", obj )
                        && fmt::ToArray( obj[ "some_array" ], arr ) && arr.length() == 1
                    );

                    Expect( "json.Count total nested value counting", true,
                        Deserialize( "{\"0\":[1,2,[3,4,[5,6],{\"0\":7}]],\"1\":{\"1\":8}}", obj )
                        && obj.Count() == 8
                    );

                    //============================
                    // ======== schema test ========
                    //============================

                    Expect( "[Schema] unevaluated properties discard", true,
                        Deserialize( "{\"unevaluated\":1,\"evaluated\":1}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"unevaluatedProperties\":false}" )
                        && obj.Length() == 0
                    );

                    json@ defaults;
                    Expect( "[Schema] external defaults", true,
                        Deserialize( "{\"inherited\":7}", defaults )
                        && Deserialize( "{}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"inherited\":{\"type\":\"integer\"}}}", false, defaults )
                        && int( obj[ "inherited" ] ) == 7
                    );

                    Expect( "[Schema] additional property array schema", true,
                        Deserialize( "{\"known\":1,\"extra\":[2]}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"known\":{\"type\":\"integer\"}},\"additionalProperties\":{\"type\":\"array\",\"items\":{\"type\":\"integer\"}},\"unevaluatedProperties\":false}" )
                        && obj[ "extra" ].is_array()
                    );

                    Expect( "[Schema] type expect", true,
                        // array != object
                        Deserialize( "[]", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\"}" )
                        && obj.is_object()
                        // object != array
                        && Deserialize( "{}", obj )
                        && !schema::Validate( obj, "{\"type\":\"array\"}" )
                        && obj.is_array()
                        // object == object && nested array == array
                        && Deserialize( "{\"a\":[]}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"nested\":{\"type\":\"array\"}}}" )
                        && obj.is_object() && obj[ "a" ].is_array()
                        // object == object && nested array != array
                        && Deserialize( "{\"a\":{}}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"nested\":{\"type\":\"array\"}}}" )
                        && obj.is_object() && obj[ "a" ].is_object()
                    );

                    Expect( "[Schema] required key", true,
                        // required key undefined
                        Deserialize( "{}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"required\":[\"required\"]}" )
                        // required key defined
                        && Deserialize( "{\"required\":0}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"required\":[\"required\"]}" )
                    );

                    Expect( "[Schema] minimum items", true,
                        // 1 != 2
                        Deserialize( "[0]", obj )
                        && !schema::Validate( obj, "{\"type\":\"array\",\"minItems\":2}" )
                        // 2 == 2
                        && Deserialize( "[0,1]", obj )
                        && schema::Validate( obj, "{\"type\":\"array\",\"minItems\":2}" )
                    );

                    Expect( "[Schema] maximum items", true,
                        // 3 != 2
                        Deserialize( "[0,1,2]", obj )
                        && !schema::Validate( obj, "{\"type\":\"array\",\"maxItems\":2}" )
                        // 2 == 2
                        && Deserialize( "[0,1]", obj )
                        && schema::Validate( obj, "{\"type\":\"array\",\"maxItems\":2}" )
                    );

                    Expect( "[Schema] minimum value", true,
                        // 1 != 2
                        Deserialize( "{\"int\":1}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"int\":{\"type\":\"integer\",\"minimum\":2}}}" )
                        // 2 == 2
                        && Deserialize( "{\"int\":2}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"int\":{\"type\":\"integer\",\"minimum\":2}}}" )
                    );

                    Expect( "[Schema] maximum value", true,
                        // 3 != 2
                        Deserialize( "{\"int\":3}", obj )
                        && !schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"int\":{\"type\":\"integer\",\"maximum\":2}}}" )
                        // 2 == 2
                        && Deserialize( "{\"int\":2}", obj )
                        && schema::Validate( obj, "{\"type\":\"object\",\"properties\":{\"int\":{\"type\":\"integer\",\"maximum\":2}}}" )
                    );

                    // ============================
                    // ======== error code test ===
                    // ============================
                    meta_api::json::Error testErr;

                    // Valid JSON
                    Expect( "[Error] Valid JSON OK", true,
                        Deserialize( "{\"key\": 1}", obj, testErr )
                        && testErr == meta_api::json::Error::OK
                    );

                    // Empty Input
                    Expect( "[Error] Empty input", true,
                        !Deserialize( "", obj, testErr )
                        && testErr == meta_api::json::Error::EMPTY_INPUT
                    );

                    // Syntax Error
                    Expect( "[Error] Syntax error", true,
                        !Deserialize( "{invalid}", obj, testErr )
                        && testErr == meta_api::json::Error::SYNTAX_ERROR
                    );

                    // File Not Found
                    Expect( "[Error] File not found", true,
                        !Deserialize( "nonexistent_file_path_test.json", obj, testErr )
                        && testErr == meta_api::json::Error::FILE_NOT_FOUND
                    );

                    Expect( "[JSON] zero-decimal float serialization", true,
                        Deserialize( "{\"value\":1.0}", obj )
                        && obj[ "value" ].Type == meta_api::json::Type::Float
                        && obj.ToString().Find( "1.0" ) != String::INVALID_INDEX
                    );

                    Expect( "[JSON] ValueOrDefault existing value", true,
                        Deserialize( "{\"value\":1}", obj )
                        && int( obj.ValueOrDefault( "value" ) ) == 1
                        && obj.Length() == 1
                    );

                    Expect( "[JSON] Remove missing key and array index", true,
                        Deserialize( "{\"value\":1}", obj )
                        && obj.Remove( "missing" ) is null
                        && obj.Length() == 1
                        && Deserialize( "[1,2]", obj )
                        && int( obj.Remove( uint(0) ) ) == 1
                        && obj.Length() == 1
                        && int( obj[ uint(0) ] ) == 2
                    );
                }
            }
        }
    }
}

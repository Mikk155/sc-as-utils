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

/// Implements interfaces for syntax suggar
// Just a prototype till VSC extension gets some more updates

#include "../v2"

interface JToken
{
    // Current type of this object.
    const meta_api::json::Type& get_Type() const;
    /// Return whatever value is a bool
    bool is_boolean() const;
    /// Return whatever value is a integer
    bool is_number_integer() const;
    /// Return whatever value is a float with decimals
    bool is_number_float() const;
    /// Return whatever value is a string
    bool is_string() const;
    /// Return whatever value is a json object
    bool is_object() const;
    /// Return whatever value is a json array
    bool is_array() const;
    /// Return whatever value is null but existent
    bool is_null() const;
    /// Return whatever value is a handle to an object
    bool is_handle() const;
    /// Return whatever value is a json object or array structure
    bool is_structured() const;
    /// Return whatever value is a number either float or integer
    bool is_number() const;
    /// Return whatever value is a non-negative integer
    bool is_number_unsigned() const;
    /// Key name of this object
    const string& get_Name() const;
    /// Internal value
    dictionaryValue@ get_Value();
    /// @param value The JSON value to assign to this token.
    meta_api::json::v2::json@ opAssign( meta_api::json::v2::json@ value );
    /// @param value The floating-point value to assign to this token.
    meta_api::json::v2::json@ opAssign( const float value );
    /// @param value The integer value to assign to this token.
    meta_api::json::v2::json@ opAssign( const int value );
    /// @param value The Boolean value to assign to this token.
    meta_api::json::v2::json@ opAssign( const bool value );
    /// @param value The string value to assign to this token.
    meta_api::json::v2::json@ opAssign( const string&in value );
    /// @param value The null value to assign to this token.
    meta_api::json::v2::json@ opAssign( const meta_api::json::v2::Null&in value );
    /**
    *   @brief Deserializes str
    *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
    *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return a valid handle
    *   @param str JSON text to parse, or a recognized JSON filename to load.
    **/
    bool Load( const string&in str );
    /// @param str JSON text to parse, or a recognized JSON filename to load.
    /// @param err Receives the error code describing the load result.
    bool Load( const string&in str, meta_api::json::Error&out err );
    /// Set key value pair, return the old value if it exists otherwise null
    /// @param keyName The key to set.
    /// @param value The JSON value to store at that key.
    meta_api::json::v2::json@ Set( const string&in keyName, meta_api::json::v2::json@ value );
    /// @param keyName The key to set.
    /// @param value The Boolean value to store at that key.
    meta_api::json::v2::json@ Set( const string&in keyName, const bool value );
    /// @param keyName The key to set.
    /// @param value The integer value to store at that key.
    meta_api::json::v2::json@ Set( const string&in keyName, const int value );
    /// @param keyName The key to set.
    /// @param value The floating-point value to store at that key.
    meta_api::json::v2::json@ Set( const string&in keyName, const float value );
    /// @param keyName The key to set.
    /// @param value The string value to store at that key.
    meta_api::json::v2::json@ Set( const string&in keyName, const string&in value );
    /// @param keyName The key to set.
    /// @param value The null value to store at that key.
    meta_api::json::v2::json@ Set( const string&in keyName, const meta_api::json::v2::Null&in value );
    string ToString();
}

// Json value
interface JValue : JToken
{
    float opConv();
    int opConv();
    bool opConv();
    string opConv();
    /// Get the value&out and return whatever the value exists or not.
    /// If strict is true only values with the same return type will be accounted
    /// @param keyName The key whose string value is requested.
    /// @param value Receives the stored string when found.
    bool Get( const string&in keyName, string&out value );
    /// @param value Receives the converted Boolean value.
    /// @param strict Require the stored value to be a Boolean when true.
    bool Get( bool&out value, bool strict = true );
    /// @param value Receives the converted integer value.
    /// @param strict Require the stored value to be an integer when true.
    bool Get( int&out value, bool strict = true );
    /// @param value Receives the converted floating-point value.
    /// @param strict Require the stored value to be a float when true.
    bool Get( float&out value, bool strict = true );
    /// @param value Receives the stored string value.
    bool Get( string&out value );
}

interface JContainer
{
    /// Return all the key names of this object/array
    const array<string>@ get_Keys() const;
    /// Clear all data. only the type remains and whatever this is an ordered object.
    void Clear();
    /// Get the length of the object.
    int Length() const;
    /// Append value to the end of the list
    /// @param value The JSON value to append.
    meta_api::json::v2::json@ Append( meta_api::json::v2::json@ value );
    /// @param value The Boolean value to append.
    meta_api::json::v2::json@ Append( const bool value );
    /// @param value The integer value to append.
    meta_api::json::v2::json@ Append( const int value );
    /// @param value The floating-point value to append.
    meta_api::json::v2::json@ Append( const float value );
    /// @param value The string value to append.
    meta_api::json::v2::json@ Append( const string&in value );
    /// @param value The null value to append.
    meta_api::json::v2::json@ Append( const meta_api::json::v2::Null&in value );
    /// Get the value at the given index
    /// @param index The zero-based array index to retrieve.
    meta_api::json::v2::json@ opIndex( uint index );
}

// Json object
interface JObject : JToken, JContainer
{
    /// Set a value of any type. "value" could be set by using Value.opAssign(T) from this object
    /// @param value The underlying dictionary value to store.
    /// @param type The JSON type to associate with the stored value.
    void SetValue( const dictionaryValue&in value, const meta_api::json::Type&in type );
    /// Return whatever this objects contains the given key
    /// @param keyName The key to look up.
    bool Contains( const string&in keyName ) const;
    /// Get the value&out and return whatever the value exists or not.
    /// If strict is true only values with the same return type will be accounted
    /// @param keyName The key whose JSON value is requested.
    /// @param value Receives the JSON value when the key exists.
    bool Get( const string&in keyName, meta_api::json::v2::json@&out value );
    /// @param keyName The key whose Boolean value is requested.
    /// @param value Receives the converted Boolean value.
    /// @param strict Require a Boolean value when true.
    bool Get( const string&in keyName, bool&out value, bool strict = true );
    /// @param keyName The key whose integer value is requested.
    /// @param value Receives the converted integer value.
    /// @param strict Require an integer value when true.
    bool Get( const string&in keyName, int&out value, bool strict = true );
    /// @param keyName The key whose floating-point value is requested.
    /// @param value Receives the converted floating-point value.
    /// @param strict Require a float value when true.
    bool Get( const string&in keyName, float&out value, bool strict = true );
    /// Get the stored value at the given key name or a default value if not exists.
    /// If store is true the default value is stored in data if not exists
    /// In this json case if the default value is null we will initialize a instance and return that
    /// @param keyName The key to look up.
    /// @param value The fallback JSON value to return, or null to create an empty JSON object.
    /// @param store Store the fallback value under the key when it is absent.
    meta_api::json::v2::json@ ValueOrDefault( const string&in keyName, meta_api::json::v2::json@ value = null, bool store = false );
    /// Get the stored value at the given key name or a default value if not exists.
    /// If store is true the default value is stored in data if not exists
    /// If strict is true only values with the same return type will be accounted
    /// @param keyName The key to look up.
    /// @param value The Boolean fallback value.
    /// @param store Store the fallback value under the key when it is absent.
    /// @param strict Require a stored Boolean value when true.
    bool ValueOrDefault( const string&in keyName, bool value, bool store = false, bool strict = true );
    /// @param keyName The key to look up.
    /// @param value The integer fallback value.
    /// @param store Store the fallback value under the key when it is absent.
    /// @param strict Require a stored integer value when true.
    int ValueOrDefault( const string&in keyName, int value, bool store = false, bool strict = true );
    /// @param keyName The key to look up.
    /// @param value The floating-point fallback value.
    /// @param store Store the fallback value under the key when it is absent.
    /// @param strict Require a stored float value when true.
    float ValueOrDefault( const string&in keyName, float value, bool store = false, bool strict = true );
    /// @param keyName The key to look up.
    /// @param value The string fallback value.
    /// @param store Store the fallback value under the key when it is absent.
    string ValueOrDefault( const string&in keyName, string&in value, bool store = false );
    /// Get the value at the given key
    /// @param keyName The key to retrieve.
    meta_api::json::v2::json@ opIndex( const string&in keyName );
}

// Json array
interface JArray : JToken, JContainer
{
}

/// Json object
class json : meta_api::json::v2::json, JValue, JObject, JArray
{
}

void test()
{
    json@ js = json();
    js.Load( "bts_rc/config.json" );

    JObject@ o = js;
}

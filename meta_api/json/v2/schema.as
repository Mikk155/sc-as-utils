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

#include "../v2"

namespace meta_api
{
    namespace json
    {
        namespace v2
        {
            namespace schema
            {
                class Validator
                {
                    private
                        bool m_Strict = true;

                    const bool get_strict() const {
                        return this.m_Strict;
                    }

                    /// @param strict Set to true to stop validation at the first invalid value.
                    Validator( bool strict )
                    {
                        this.m_Strict = strict;
                    }

                    Validator() {}

                    private
                        uint errors = 0;

                    /**
                    *   @brief Check whether a JSON value matches the type named by a schema.
                    *   @param obj The JSON value whose type is checked.
                    *   @param schema The schema object containing the expected type.
                    *   @param name The path or label used to identify the value in validation errors.
                    **/
                    bool is_type( json@ obj, json@ schema, const string&in name, json@ defaults )
                    {
                        if( !schema.Contains( "type" ) )
                        {
                            this.errors++;
                            g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "%1 expected \"type\" at schema but is undefined!\n", name );
                            return false;
                        }

                        string expectedTypeString = string( schema[ "type" ] );
                        Type expectedType = Type::FromString( expectedTypeString );
                        bool isType = false;

                        if( expectedTypeString.IsEmpty() )
                        {
                            this.errors++;
                            g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "Unexpected empty type at schema!\n" );
                            return false;
                        }

                        switch( expectedType )
                        {
                            case Type::Object:
                                isType = obj.is_object();
                            break;
                            case Type::Array:
                                isType = obj.is_array();
                            break;
                            case Type::String:
                                isType = obj.is_string();
                            break;
                            case Type::Integer:
                                isType = obj.is_number_integer();
                            break;
                            case Type::Float:
                                isType = obj.is_number();
                            break;
                            case Type::Boolean:
                                isType = obj.is_boolean();
                            break;
                            case Type::Null:
                                isType = obj.is_null();
                            break;
                            default:
                                this.errors++;
                                g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "schema unknown \"type\" %1\n", expectedTypeString );
                                if( true )
                                    return false;
                            break;
                        }

                        if( isType )
                            return true;

                        this.errors++;
                        g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "%1 Expected %2 got %3\n", name, expectedTypeString, Type::ToString(obj.Type) );

                        if( !this.strict )
                        {
                            obj.Clear();
                            obj.SetType( expectedType );

                            if( schema.Contains( "default" ) )
                                obj.opAssign( schema[ "default" ] );
                            else if( defaults !is null )
                                obj.opAssign( defaults.Copy() );
                        }

                        return false;
                    }

                    /**
                    *   @brief Validate a JSON value recursively against a schema object.
                    *   @param obj The JSON value to validate; non-strict validation may modify it.
                    *   @param schema The schema object describing the expected structure and constraints.
                    *   @param name The path or label used to identify the value in validation errors.
                    **/
                    private bool Validate( json@ obj, json@ schema, const string&in name, json@ defaults )
                    {
                        if( defaults !is null && obj.Length() <= 0 )
                            obj.opAssign( defaults.Copy() );

                        if( !this.is_type( obj, schema, name, defaults ) && this.strict )
                            return false;

                        switch( obj.Type )
                        {
                            case Type::Object:
                            case Type::Array:
                            {
                                json@ schemaProperties = schema.ValueOrDefault( ( obj.is_object() ? "properties" : "items" ) ).Copy();

                                // Array specific validations
                                if( obj.is_array() )
                                {
                                    uint uiTemp;

                                    if( schema.Get( "minItems", uiTemp ) && obj.Length() < uiTemp )
                                    {
                                        this.errors++;
                                        g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "%1 array has less items than minimum expected %2 or more. got %3\n", name, uiTemp, obj.Length() );
                                        if( this.strict )
                                            return false;
                                    }

                                    if( schema.Get( "maxItems", uiTemp ) && obj.Length() > uiTemp )
                                    {
                                        this.errors++;
                                        g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "%1 array has more items than maximum expected %2 or less. got %3\n", name, uiTemp, obj.Length() );
                                        if( this.strict )
                                            return false;
                                    }
                                }
                                else
                                {
                                    json@ additionalPropertiesSchema = schema[ "additionalProperties" ];
                                    bool hasAdditionalProperties = additionalPropertiesSchema !is null;
                                    bool isArrayAdditionalProperties = hasAdditionalProperties && string( additionalPropertiesSchema[ "type" ] ) == "array";
                                    bool allowUnevaluatedProperties = schema.ValueOrDefault( "unevaluatedProperties", true );

                                    const array<string>@ keys = obj.Keys;
                                    uint objlength = obj.Length();

                                    for( uint ui = 0; ui < objlength; ui++ )
                                    {
                                        string key = keys[ui];

                                        if( schemaProperties.Contains( key ) )
                                            continue;

                                        if( isArrayAdditionalProperties )
                                        {
                                            schemaProperties.Set( key, additionalPropertiesSchema.Copy() );
                                            continue;
                                        }

                                        if( hasAdditionalProperties && additionalPropertiesSchema.Contains( key ) )
                                        {
                                            schemaProperties.Set( key, additionalPropertiesSchema[ key ].Copy() );
                                            continue;
                                        }

                                        if( allowUnevaluatedProperties )
                                            continue;

                                        this.errors++;
                                        g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "%1 got unevaluated property \"%2\" which is not allowed!\n", name, key );
                                        if( this.strict )
                                            return false;

                                        --objlength;
                                        obj.Remove( ui );
                                        --ui;
                                    }

                                    // Whatever required properties in schema are defined in obj
                                    if( schema.Contains( "required" ) )
                                    {
                                        json@ required = schema.ValueOrDefault( "required" );

                                        uint requiredlength = required.Length();

                                        for( uint ui = 0; ui < requiredlength; ui++ )
                                        {
                                            string key = string( required[ui] );

                                            if( !obj.Contains( key ) )
                                            {
                                                this.errors++;
                                                g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "%1 missing required key \"%2\"\n", name, key );
                                                if( this.strict )
                                                    return false;
                                            }
                                        }
                                    }
                                }

                                // validate all properties
                                uint propertieslength = schemaProperties.Length();

                                for( uint ui = 0; ui < propertieslength; ui++ )
                                {
                                    json@ pair = schemaProperties[ui];

                                    json@ childObj = obj[ pair.Name ];
                                    json@ defaultChild = ( defaults !is null ? defaults[ pair.Name ] : null );

                                    if( childObj is null )
                                    {
                                        if( !this.strict )
                                        {
                                            if( pair.Contains( "default" ) )
                                            {
                                                // -TODO DeepCopy
                                                @childObj = pair[ "default" ].Copy();
                                                obj.Set( pair.Name, childObj );
                                            }
                                            else if( defaultChild !is null )
                                            {
                                                @childObj = defaultChild.Copy();
                                                obj.Set( pair.Name, childObj );
                                            }
                                        }

                                        if( childObj is null )
                                            continue;
                                    }

                                    string childName;
                                    snprintf( childName, "%1->%2", name, pair.Name );
                                    if( debug )
                                        g_Game.AlertMessage( at_console, GetLogPrefix( int( Version::V2 ) ) + "Validating %1\n", childName );

                                    bool result = this.Validate( childObj, pair, childName, defaultChild );

                                    if( this.strict && result == false )
                                        return false;
                                }

                                break;
                            }
                            case Type::Integer:
                            case Type::Float:
                            {
                                float fTemp;
                                float fValue;

                                if( schema.Get( "minimum", fTemp, false ) && obj.Get( fValue, false ) && fValue < fTemp )
                                {
                                    obj.opAssign(fTemp);
                                    this.errors++;
                                    g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "%1 value is lesser than minimum expected %2 or more. got %3\n", name, fTemp, fValue );
                                    if( this.strict )
                                        return false;
                                }

                                if( schema.Get( "maximum", fTemp, false ) && obj.Get( fValue, false ) && fValue > fTemp )
                                {
                                    obj.opAssign(fTemp);
                                    this.errors++;
                                    g_Game.AlertMessage( at_error, GetLogPrefix( int( Version::V2 ) ) + "%1 value is higher than maximum expected %2 or less. got %3\n", name, fTemp, fValue );
                                    if( this.strict )
                                        return false;
                                }
                                break;
                            }
                        }

                        return ( this.errors == 0 );
                    }

                    /**
                    *   @brief Validate a JSON value against a schema object using this validator's strictness.
                    *   @param obj The JSON value to validate.
                    *   @param schema The schema object describing the expected structure and constraints.
                    **/
                    bool Validate( json@ obj, json@ schema, json@ defaults )
                    {
                        return this.Validate( obj, schema, "<root>", defaults );
                    }
                }

                /// Validate obj against schema
                /// strict: if true the method will return false right away stoping the validation.
                /// Otherwise the validation will keep going removing invalid values, attempting to set defaults if provided by the schema.
                /// @param obj The JSON value to validate; non-strict validation may modify it.
                /// @param schema The schema object describing the expected structure and constraints.
                /// @param strict Set to true to stop on the first invalid value; false continues and may remove invalid values or apply defaults.
                /// @param defaults Optional external fallback values for missing or invalid properties.
                bool Validate( json@ obj, json@ schema, bool strict = false, json@ defaults = null )
                {
                    Validator validator( strict );
                    return validator.Validate( obj, schema, defaults );
                }

                /// Validate obj against schema
                /// strict: if true the method will return false right away stoping the validation.
                /// Otherwise the validation will keep going removing invalid values, attempting to set defaults if provided by the schema.
                /// @param obj The JSON value to validate; non-strict validation may modify it.
                /// @param schema JSON text describing the schema.
                /// @param strict Set to true to stop on the first invalid value; false continues and may remove invalid values or apply defaults.
                /// @param defaults Optional external fallback values for missing or invalid properties.
                bool Validate( json@ obj, const string&in schema, bool strict = false, json@ defaults = null )
                {
                    json@ schemaObject;
                    return Deserialize( schema, schemaObject ) && Validate( obj, schemaObject, strict, defaults );
                }
            } // schema
        } // v2
    } // json
} // meta_api

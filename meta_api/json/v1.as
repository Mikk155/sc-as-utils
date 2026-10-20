#include "../json"

namespace meta_api
{
    namespace json
    {
        /// Version 1 of Json. conversion to/from dictionary.
        /// It is recommended to use V2 instead as has way more features for configuring. V1 is ideal for simple objects as may be faster and uses less memory.
        /// Serializing loses data: "null" values are skiped. booleans are turned into integers. the object loses ordering. Arrays are also serialized as objects.
        /// Deserializing "null" values are skiped. array items are converted into a dictionary object where the key names are the item indexing
        namespace v1
        {
            class __Deserializer__ : meta_api::json::parser::Deserializer
            {
                const meta_api::json::Version GetVersion() const override {
                    return meta_api::json::Version::V1;
                }

                /**
                *   @brief Parse the current JSON object or array into a dictionary.
                *   @param obj Receives the parsed key-value pairs.
                *   @param objectType The JSON container type being parsed.
                **/
                bool Parse( dictionary&out obj, const meta_api::json::Type&in objectType )
                {
                    obj.deleteAll();

                    if( objectType != meta_api::json::Type::Object && objectType != meta_api::json::Type::Array )
                    {
                        return false;
                    }

                    meta_api::json::parser::KeyValuePair@ pair;

                    while( this.Advance( objectType, pair ) )
                    {
                        switch( pair.type )
                        {
                            case meta_api::json::Type::Object:
                            case meta_api::json::Type::Array:
                            {
                                dictionary objChild;
                                if( this.Parse( objChild, pair.type ) )
                                    obj[ pair.key ] = objChild;
                                break;
                            }
                            case meta_api::json::Type::String:
                            {
                                obj.set( pair.key, pair.value_string );
                                break;
                            }
                            case meta_api::json::Type::Float:
                            {
                                obj.set( pair.key, pair.value_float );
                                break;
                            }
                            case meta_api::json::Type::Integer:
                            {
                                obj.set( pair.key, pair.value_int );
                                break;
                            }
                            case meta_api::json::Type::Boolean:
                            {
                                obj.set( pair.key, pair.value_bool );
                                break;
                            }
                            case meta_api::json::Type::Null:
                            {
                                obj.set( pair.key, "__null__" );
                                break;
                            }
                        }
                    }
                    return this.Ok;
                }
            }

            /**
            *   @brief Determine whether a dictionary represents an array or an object.
            *   @param obj The dictionary whose keys are checked for sequential numeric indexes.
            **/
            meta_api::json::Type __GetDictionaryType__( dictionary&in obj )
            {
                meta_api::json::Type type = meta_api::json::Type::Array;

                /// Confirm it's an "array" type where all keys are numeric and corresponds to indexes
                array<string>@ keys = obj.getKeys();
                uint length = keys.length();
                for( uint ui = 0; ui < length; ui++ )
                {
                    if( !obj.exists( string( ui ) ) )
                    {
                        type = meta_api::json::Type::Object;
                        break;
                    }
                }
                return type;
            }

            /**
            *   @brief Serialize a dictionary using an existing serializer.
            *   @param obj The dictionary to serialize.
            *   @param Serializer The serializer that receives the dictionary's entries.
            **/
            string Serialize( dictionary&in obj, meta_api::json::parser::Serializer@ Serializer )
            {
                string strValue;
                dictionary@ objValue = null; 
                int iValue;
                float fValue;

                array<string>@ keys = obj.getKeys();
                uint length = keys.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    string key = keys[ui];

                    if( obj.get( key, strValue ) )
                    {
                        if( strValue == "__null__" )
                            Serializer.KeyValue( key, "null", meta_api::json::Type::Null );
                        else
                            Serializer.KeyValue( key, strValue, meta_api::json::Type::String );
                    }
                    else if( obj.get( key, @objValue ) )
                    {
                        auto objType = meta_api::json::v1::__GetDictionaryType__(objValue);
                        Serializer.KeyValue( key, meta_api::json::v1::Serialize( objValue, Serializer.Object( objType ) ), objType );
                    }
                    else if( obj.get( key, fValue ) )
                    {
                        Serializer.KeyValue( key, fValue, meta_api::json::Type::Float );
                    }
                    else if( obj.get( key, iValue ) )
                    {
                        Serializer.KeyValue( key, iValue, meta_api::json::Type::Integer );
                    }
                    else
                    {
                        Serializer.KeyValue( key, String::EMPTY_STRING, meta_api::json::Type::Undefined );
                    }
                }

                return Serializer.Serialize();
            }

            /**
            *   @brief Serializes obj
            *   filename: if provided is a path to write to a file at scripts/(module type)/store/(filename).json
            *   If the object failed to parse for any reason it will write "{}" to the file only if the file doesn't exists
            *   @param obj The dictionary to serialize.
            *   @param filename Optional output filename; an empty string returns the serialized text instead.
            *   @param indents The indentation mode used to format the output.
            *   @param style The placement style for nested object and array delimiters.
            **/
            string Serialize(
                dictionary&in obj,
                const string&in filename = String::EMPTY_STRING,
                const meta_api::json::parser::Indentation&in indents = meta_api::json::parser::Indentation::AllTogether,
                const meta_api::json::parser::Style&in style = meta_api::json::parser::Style::AllMan
            )
            {
                return meta_api::json::v1::Serialize(
                    obj,
                    meta_api::json::parser::Serializer(
                        1,
                        filename,
                        meta_api::json::v1::__GetDictionaryType__( obj ),
                        style,
                        indents,
                        meta_api::json::Version::V1
                    )
                );
            }

            /**
            *   @brief Deserializes str into obj,
            *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
            *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return {}
            *   @param str JSON text to parse, or a recognized JSON filename to load.
            *   @param obj Receives the parsed JSON contents as a dictionary.
            **/
            bool Deserialize( const string&in str, dictionary&out obj )
            {
                meta_api::json::v1::__Deserializer__ Deserializer();
                Deserializer.SetSerialized(str);
#if METAMOD_PLUGIN_ASLP
                if( __METAMOD__ )
                {
                    if( Deserializer.IsFile )
                        return aslp::json::Deserialize( Deserializer.FileName, obj );
                    return aslp::json::Deserialize( Deserializer.buffer, obj );
                }
#endif
                return Deserializer.Parse( obj, Deserializer.Initialize() );
            }

            /**
            *   @brief Deserialize JSON text or a file into a dictionary and report the result code.
            *   @param str JSON text to parse, or a recognized JSON filename to load.
            *   @param obj Receives the parsed JSON contents as a dictionary.
            *   @param err Receives the error code describing the deserialization result.
            **/
            bool Deserialize( const string&in str, dictionary&out obj, meta_api::json::Error&out err )
            {
                meta_api::json::v1::__Deserializer__ Deserializer();
                Deserializer.SetSerialized(str);
#if METAMOD_PLUGIN_ASLP
                if( __METAMOD__ )
                {
                    bool result = false;
                    if( Deserializer.IsFile )
                        result = aslp::json::Deserialize( Deserializer.FileName, obj );
                    else
                        result = aslp::json::Deserialize( Deserializer.buffer, obj );
                    if( result )
                        err = meta_api::json::Error::OK;
                    else
                        err = meta_api::json::Error::SYNTAX_ERROR;
                    return result;
                }
#endif
                bool result = Deserializer.Parse( obj, Deserializer.Initialize() );
                err = Deserializer.ErrorCode;
                return result;
            }
        }
    }
}

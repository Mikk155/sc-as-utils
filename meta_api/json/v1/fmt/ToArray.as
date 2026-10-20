namespace meta_api
{
    namespace json
    {
        namespace v1
        {
            namespace fmt
            {
                /**
                *   @brief converts the given obj to a list of string.
                *   NOTE: Any type that is not a string will be skipped.
                *   @param obj The dictionary whose numeric keys are converted to array elements.
                *   @param List Receives the converted string values.
                **/
                bool ToArray( dictionary@ obj, array<string>@&out List )
                {
                    if( obj is null )
                        return false;

                    if( List is null )
                        @List = {};

                    uint size = obj.getSize();

                    List.resize( size );

                    bool hasAny;

                    for( uint ui = 0; ui < size; ui++ )
                    {
                        int iValue;
                        float fValue;
                        string strValue;
                        string key = string(ui);
                        if( obj.get( key, strValue ) )
                            List[ui] = strValue;
                        else if( obj.get( key, fValue ) )
                            List[ui] = string(fValue);
                        else if( obj.get( key, iValue ) )
                            List[ui] = string(iValue);
                        else
                            continue;
                        hasAny = true;
                    }

                    return hasAny;
                }

                /**
                *   @brief converts the given obj to a list of string.
                *   NOTE: Any type that is not a string will be skipped.
                *   @param obj The dictionary value to convert; it must contain a dictionary handle.
                *   @param List Receives the converted string values.
                **/
                bool ToArray( dictionaryValue&in obj, array<string>@&out List )
                {
                    return ToArray( cast<dictionary@>( obj ), List );
                }

                /**
                *   @brief converts the given obj to a list of dictionaryValue
                *   @param obj The dictionary whose numeric keys are copied into an array.
                *   @param List Receives the copied values.
                **/
                bool ToArray( dictionary&in obj, array<dictionaryValue>@&out List )
                {
                    if( obj is null )
                        return false;

                    if( List is null )
                        @List = {};

                    uint size = obj.getSize();

                    List.resize( size );

                    for( uint ui = 0; ui < size; ui++ )
                    {
                        dictionaryValue value;
                        if( obj.get( string( ui ), value ) )
                            List[ ui ] = value;
                    }

                    return true;
                }

                /**
                *   @brief Convert a dictionary value containing a dictionary into an array of values.
                *   @param obj The dictionary value to convert; it must contain a dictionary handle.
                *   @param List Receives the copied dictionary values.
                **/
                bool ToArray( dictionaryValue&in obj, array<dictionaryValue>@&out List )
                {
                    return ToArray( cast<dictionary@>( obj ), List );
                }
            } // fmt
        } // v2
    } // json
} // meta_api

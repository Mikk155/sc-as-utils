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

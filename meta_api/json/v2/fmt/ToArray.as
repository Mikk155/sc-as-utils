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
        namespace v2
        {
            namespace fmt
            {
                /// If the json is type of Array or Object converts the values to the array type.
                /// If store is true allocate it in the json.Value and set the list handle to that array and updates the type to Handle.
                /// @param json The JSON object or array, or a handle to an array of the requested element type.
                /// @param list Receives the converted array.
                /// @param strict Require element values to match the target type when true.
                /// @param store Store the resulting array handle in the JSON value when true.
                bool ToArray( meta_api::json::v2::json@ json, array<float>@&out list, bool strict = false, bool store = false )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::Type::Array:
                            case meta_api::json::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    float fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                if( store )
                                    json.SetValue( json.Value.opAssign(@list), meta_api::json::Type::Handle );
                                return true;
                            }
                            case meta_api::json::Type::Handle:
                            {
                                array<float>@ ar = cast<array<float>@>( json.Value );
                                if( ar !is null ) {
                                    @list = ar;
                                    return true;
                                }
                                break;
                            }
                        }
                    }
                    return false;
                }
                /// If the json is type of Array or Object converts the values to the array type.
                /// If store is true allocate it in the json.Value and set the list handle to that array and updates the type to Handle.
                /// @param json The JSON object or array, or a handle to an array of the requested element type.
                /// @param list Receives the converted array.
                /// @param strict Require element values to match the target type when true.
                /// @param store Store the resulting array handle in the JSON value when true.
                bool ToArray( meta_api::json::v2::json@ json, array<int>@&out list, bool strict = false, bool store = false )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::Type::Array:
                            case meta_api::json::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    int fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                if( store )
                                    json.SetValue( json.Value.opAssign(@list), meta_api::json::Type::Handle );
                                return true;
                            }
                            case meta_api::json::Type::Handle:
                            {
                                array<int>@ ar = cast<array<int>@>( json.Value );
                                if( ar !is null ) {
                                    @list = ar;
                                    return true;
                                }
                                break;
                            }
                        }
                    }
                    return false;
                }
                /// If the json is type of Array or Object converts the values to the array type.
                /// If store is true allocate it in the json.Value and set the list handle to that array and updates the type to Handle.
                /// @param json The JSON object or array, or a handle to an array of the requested element type.
                /// @param list Receives the converted array.
                /// @param strict Require element values to match the target type when true.
                /// @param store Store the resulting array handle in the JSON value when true.
                bool ToArray( meta_api::json::v2::json@ json, array<bool>@&out list, bool strict = false, bool store = false )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::Type::Array:
                            case meta_api::json::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    bool fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                if( store )
                                    json.SetValue( json.Value.opAssign(@list), meta_api::json::Type::Handle );
                                return true;
                            }
                            case meta_api::json::Type::Handle:
                            {
                                array<bool>@ ar = cast<array<bool>@>( json.Value );
                                if( ar !is null ) {
                                    @list = ar;
                                    return true;
                                }
                                break;
                            }
                        }
                    }
                    return false;
                }
                /// If the json is type of Array or Object converts the values to the array type.
                /// If store is true allocate it in the json.Value and set the list handle to that array and updates the type to Handle.
                /// @param json The JSON object or array, or a handle to an array of the requested element type.
                /// @param list Receives the converted array.
                /// @param strict Keep only string elements when true; convert values to text when false.
                /// @param store Store the resulting array handle in the JSON value when true.
                bool ToArray( meta_api::json::v2::json@ json, array<string>@&out list, bool strict = false, bool store = false )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::Type::Array:
                            case meta_api::json::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    if( strict )
                                    {
                                        if( value.is_string() )
                                            list.insertLast( string( value ) );
                                    }
                                    else
                                    {
                                        list.insertLast( value.ToString() );
                                    }
                                }

                                if( list.length() == 0 )
                                    return false;

                                if( store )
                                    json.SetValue( json.Value.opAssign(@list), meta_api::json::Type::Handle );
                                return true;
                            }
                            case meta_api::json::Type::Handle:
                            {
                                array<string>@ ar = cast<array<string>@>( json.Value );
                                if( ar !is null ) {
                                    @list = ar;
                                    return true;
                                }
                                break;
                            }
                        }
                    }
                    return false;
                }
            } // fmt
        } // v2
    } // json
} // meta_api

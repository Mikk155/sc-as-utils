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
            namespace utils
            {
                /**
                *   @brief Return whatever the given obj has an object at key containing the current map name in it.
                *   @param obj The dictionary that may contain the map list.
                *   @param key The dictionary key holding the list of map names.
                **/
                bool IsMapListed( dictionary@ obj, const string&in key = "map_blacklist" )
                {
                    dictionary map_blacklist;
                    if( obj.get( key, map_blacklist ) )
                    {
                        string mapname = string( g_Engine.mapname );

                        for( uint ui = 0; ui < map_blacklist.getSize(); ui++ )
                        {
                            if( mapname == string( map_blacklist[ ui ] ) )
                            {
                                return true;
                            }
                        }
                    }
                    return false;
                }
            } // fmt
        } // v2
    } // json
} // meta_api

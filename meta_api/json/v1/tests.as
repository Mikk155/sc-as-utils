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

/// Run tests for json
#include "../v1"
#include "fmt/core"
#include "utils/core"
#include "../tests"

namespace meta_api
{
    namespace json
    {
        namespace v1
        {
            class Test : meta_api::json::ITest
            {
                Test()
                {
                    meta_api::json::tests::Register(this);
                }

                const Version GetVersion() override
                {
                    return Version::V1;
                }

                /// @param serialized JSON text or a JSON filename to pass to the generic deserializer.
                bool DeserializeGeneric( const string&in serialized ) override
                {
                    dictionary obj;
                    return Deserialize( serialized, obj );
                }

                /// @param serialized JSON text or a JSON filename containing the supported value types.
                bool DeserializeAllTypes( const string&in serialized ) override
                {
                    dictionary obj;
                    return Deserialize( serialized, obj );
                }

                void AdditionalTests() override
                {
                    dictionary obj;

                    Expect( "utils::IsMapListed current map in list", true,
                        Deserialize( "{\"map_blacklist\":[\"" + string( g_Engine.mapname ) + "\"]}", obj ) && utils::IsMapListed( obj )
                    );

                    array<string> arr;
                    Expect( "fmt::ToArray conversion", true,
                        fmt::ToArray( obj[ "map_blacklist" ], arr ) && arr.length() == 1
                    );
                }
            }
        }
    }
}

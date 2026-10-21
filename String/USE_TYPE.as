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

namespace String
{
    /**
     * Converts an entity use type to a readable string.
     *
     * @param input Use type to convert.
     * @param enumName If true, returns the enum-style name (such as "USE_ON");
     *                  otherwise returns the short label (such as "On").
     */
    string from_USE_TYPE( const USE_TYPE&in input, bool enumName = false )
    {
        switch( input )
        {
            case USE_ON:
                return ( enumName ? "USE_ON" : "On" );
            case USE_SET:
                return ( enumName ? "USE_SET" : "Set" );
            case USE_TOGGLE:
                return ( enumName ? "USE_TOGGLE" : "Toggle" );
            case USE_KILL:
                return ( enumName ? "USE_KILL" : "Kill" );
            case USE_OFF:
            default:
                return ( enumName ? "USE_OFF" : "Off" );
        }
    }
}

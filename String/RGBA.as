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

#include "find_delimiter"

namespace String
{
    /**
     * Parses a string into an RGBA color.
     *
     * @param input Text containing the red, green, blue, and alpha components.
     * @param delimiter Character separating the components. When '' empty, a comma is
     *                  chosen if present in input; otherwise a space is used.
     */
    RGBA to_RGBA( const string&in input, char delimiter = ' ' )
    {
        delimiter = find_delimiter(input, delimiter);
        RGBA rgba;
        g_Utility.StringToRGBA( rgba, input, delimiter );
        return rgba;
    }

    /**
     * Formats an RGBA color as four components separated by a character.
     *
     * @param input Color whose red, green, blue, and alpha components are formatted.
     * @param delimiter Character placed between adjacent components. Defaults to a space.
     */
    string from_RGBA( const RGBA&in input, const char&in delimiter = ' ' )
    {
        string output;
        snprintf( output, "%1%2%3%4%5%6%7", input.r, delimiter, input.g, delimiter, input.b, delimiter, input.a );
        return output;
    }
}

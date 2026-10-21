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
     * Parses a string into a three-dimensional vector.
     *
     * @param input Text containing the x, y, and z components.
     * @param delimiter Character separating the components. When '' empty, a comma is
     *                  chosen if present in input; otherwise a space is used.
     */
    Vector to_Vector( const string&in input, char delimiter = ' ' )
    {
        Vector vec;
        g_Utility.StringToVector( vec, input, find_delimiter(input, delimiter) );
        return vec;
    }

    /**
     * Formats a three-dimensional vector as three components separated by a character.
     *
     * @param input Vector whose x, y, and z components are formatted.
     * @param delimiter Character placed between adjacent components. Defaults to a space.
     * @param makeRound When true makes a integer conversion on each vector component
     */
    string from_Vector( const Vector&in input, const char&in delimiter = ' ', bool makeRound = false )
    {
        string output;
        if( makeRound )
        {
            snprintf( output, "%1%2%3%4%5", int(input.x), delimiter, int(input.y), delimiter, int(input.z) );
        }
        else
        {
            snprintf( output, "%1%2%3%4%5", input.x, delimiter, input.y, delimiter, input.z );
        }
        return output;
    }
}

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
     * Parses common boolean text representations.
     *
     * @param input Text interpreted as true when its numeric value is nonzero or
     *              its case-insensitive value is "true"; otherwise false.
     */
    bool to_bool( const string&in input )
    {
        if( atoi( input ) != 0 )
            return true;

        string stringCheck = input;
        stringCheck.ToLowercase();
        return ( stringCheck == "true" );
    }

    /**
     * Converts a boolean value to text.
     *
     * @param input Boolean value to format.
     * @param make_digit If true, returns "1" or "0"; otherwise returns "True" or "False".
     */
    string from_bool( bool input, bool make_digit = false )
    {
        if( make_digit )
        {
            return ( input ? "1" : "0" );
        }
        return ( input ? "True" : "False" );
    }
}

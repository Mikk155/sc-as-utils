namespace String
{
    /**
     * Parses a string into a three-dimensional vector.
     *
     * @param input Text containing the x, y, and z components.
     * @param delimiter Character separating the components. When '\\0', a comma is
     *                  chosen if present in input; otherwise a space is used.
     */
    Vector to_Vector( const string&in input, char delimiter = '\0' )
    {
        if( delimiter == '\0' )
        {
            if( input.Find( "," ) != String::INVALID_INDEX )
            {
                delimiter = ',';
            }
            else
            {
                delimiter = ' ';
            }
        }
        Vector vec;
        g_Utility.StringToVector( vec, input, delimiter );
        return vec;
    }

    /**
     * Formats a three-dimensional vector as three components separated by a character.
     *
     * @param input Vector whose x, y, and z components are formatted.
     * @param delimiter Character placed between adjacent components. Defaults to a space.
     */
    string to_string( const Vector&in input, const char&in delimiter = ' ' )
    {
        string output; // -TODO method for digit count and wrap x, y, z in it
        snprintf( output, "%1%2%3%4%5", input.x, delimiter, input.y, delimiter, input.z );
        return output;
    }
}

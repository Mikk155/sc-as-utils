namespace String
{
    /**
     * Parses a string into a two-dimensional vector using its first two components.
     *
     * @param input Text containing the x and y components (and optionally a third component).
     * @param delimiter Character separating the components. When '\\0', a comma is
     *                  chosen if present in input; otherwise a space is used.
     */
    Vector2D to_Vector( const string&in input, char delimiter = '\0' )
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
        return vec.Make2D();
    }

    /**
     * Formats a two-dimensional vector as two components separated by a character.
     *
     * @param input Vector whose x and y components are formatted.
     * @param delimiter Character placed between the components. Defaults to a space.
     */
    string to_string( const Vector2D&in input, const char&in delimiter = ' ' )
    {
        string output; // -TODO method for digit count and wrap x, y in it
        snprintf( output, "%1%2%3", input.x, delimiter, input.y );
        return output;
    }
}

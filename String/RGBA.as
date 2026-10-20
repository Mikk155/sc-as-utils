namespace String
{
    /**
     * Parses a string into an RGBA color.
     *
     * @param input Text containing the red, green, blue, and alpha components.
     * @param delimiter Character separating the components. When '\\0', a comma is
     *                  chosen if present in input; otherwise a space is used.
     */
    RGBA to_RGBA( const string&in input, char delimiter = '\0' )
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
    string to_string( const RGBA&in input, const char&in delimiter = ' ' )
    {
        string output;
        snprintf( output, "%1%2%3%4%5%6%7", input.r, delimiter, input.g, delimiter, input.b, delimiter, input.a );
        return output;
    }
}

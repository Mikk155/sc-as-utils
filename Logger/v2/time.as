namespace Logger
{
    namespace time
    {
        string date_format = "%d/%m/%Y %H:%M:%S";

        void format( const string&in strIn, string&out strOut )
        {
            strOut = "";

            string strFormated;
            if( DateTime().Format( strFormated, date_format ) > 0 )
            {
                strOut = "[" + strFormated + "] ";
            }

            strOut.opAddAssign( strIn );
        }

        string format( const string&in strIn )
        {
            string strOut;
            format( strIn, strOut );
            return strOut;
        }
    }
}

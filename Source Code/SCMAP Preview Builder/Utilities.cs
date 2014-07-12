using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SCMAPTools
{
    class Utilities
    {
        public static float TranslateTextureTileValue(float input)
        {
            float someVar = 256.0f; //This may be variable based on map size, but it may just be based on the texture size.
            return someVar / input;
        }
    }
}

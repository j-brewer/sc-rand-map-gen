using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SlimDX.Direct3D10;
using System.IO;
using System.IO.Compression;
using SlimDX;

namespace SCMAPTools
{
    class TextureLoader
    {
        private SlimDX.Direct3D9.PresentParameters PP;
        private System.Windows.Forms.Control DummyControl;
        private SlimDX.Direct3D9.Device d1;

        public TextureLoader()
        {
            PP = new SlimDX.Direct3D9.PresentParameters();
            PP.BackBufferFormat = SlimDX.Direct3D9.Format.X8R8G8B8;
            DummyControl = new System.Windows.Forms.Control();
            d1 = new SlimDX.Direct3D9.Device(new SlimDX.Direct3D9.Direct3D(), 0, SlimDX.Direct3D9.DeviceType.Hardware, DummyControl.Handle, SlimDX.Direct3D9.CreateFlags.HardwareVertexProcessing, PP);
        }
        public Texture2D LoadTextureFromEnvScd(string texturePath, SlimDX.Direct3D10.Device g)
        {
            string sPath = "C:\\Program Files (x86)\\THQ\\Gas Powered Games\\Supreme Commander - Forged Alliance\\gamedata\\env.scd";
            return LoadTextureFromScd(texturePath, g, sPath);
        }
        public Texture2D LoadTextureFromTexturesScd(string texturePath, SlimDX.Direct3D10.Device g)
        {
            string sPath = "C:\\Program Files (x86)\\THQ\\Gas Powered Games\\Supreme Commander - Forged Alliance\\gamedata\\textures.scd";
            return LoadTextureFromScd(texturePath, g, sPath);
        }
        private Texture2D LoadTextureFromScd(string texturePath, SlimDX.Direct3D10.Device g, string scdpath)
        {
            Texture2D rt = null;
            ZipArchive z = ZipFile.OpenRead(scdpath);

            if (texturePath.Length > 0)
            {
                ZipArchiveEntry zae = FindEntry(texturePath, z);
                if ((zae != null))
                {
                    rt = SlimDX.Direct3D10.Texture2D.FromStream(g, zae.Open(), (int)zae.Length);
                }
                else
                {
                    throw new FileNotFoundException("The specified texture (\"" + texturePath + "\") not found in env.scd.");
                }
            }
            return rt;
        }

        public ShaderResourceView LoadTextureCubeFromEnvScd(string texturePath, SlimDX.Direct3D10.Device g)
        {
            string sPath = "C:\\Program Files (x86)\\THQ\\Gas Powered Games\\Supreme Commander - Forged Alliance\\gamedata\\env.scd";
            return LoadTextureCubeFromScd(texturePath, g, sPath);
        }
        public ShaderResourceView LoadTextureCubeFromTexturesScd(string texturePath, SlimDX.Direct3D10.Device g)
        {
            string sPath = "C:\\Program Files (x86)\\THQ\\Gas Powered Games\\Supreme Commander - Forged Alliance\\gamedata\\textures.scd";
            return LoadTextureCubeFromScd(texturePath, g, sPath);
        }

        private ShaderResourceView LoadTextureCubeFromScd(string texturePath, SlimDX.Direct3D10.Device g, string scdpath)
        {
            ShaderResourceView rt = null;
            ZipArchive z = ZipFile.OpenRead(scdpath);

            if (texturePath.Length > 0)
            {
                ZipArchiveEntry zae = FindEntry(texturePath, z);
                if ((zae != null))
                {
                    rt = SlimDX.Direct3D10.ShaderResourceView.FromStream(g, zae.Open(), (int)zae.Length);
                }
                else
                {
                    throw new FileNotFoundException("The specified texture (\"" + texturePath + "\") not found in env.scd.");
                }
            }
            return rt;
        }

        public Texture2D LoadDdsTexture(SlimDX.Direct3D9.Texture dx9Texture, SlimDX.Direct3D10.Device g)
        {
            DataStream ds = SlimDX.Direct3D9.Texture.ToStream(dx9Texture, SlimDX.Direct3D9.ImageFileFormat.Dds);
            return SlimDX.Direct3D10.Texture2D.FromStream(g, ds, (int)ds.Length);
        }

        public Texture2D LoadDdsTexture(byte[] data, SlimDX.Direct3D10.Device g)
        {
            return SlimDX.Direct3D10.Texture2D.FromMemory(g, data);
        }

        public Texture2D LoadDdsTexture(string filepath, SlimDX.Direct3D10.Device g)
        {
            return SlimDX.Direct3D10.Texture2D.FromFile(g, filepath);
        }

        private static ZipArchiveEntry FindEntry(string path, ZipArchive za)
        {
            ZipArchiveEntry rt = null;
            System.Collections.ObjectModel.ReadOnlyCollection<ZipArchiveEntry> currEntryList = za.Entries;
            path = path.Remove(0, 1);
            foreach (ZipArchiveEntry entry in za.Entries)
            {
                if (entry.FullName.Equals(path, StringComparison.InvariantCultureIgnoreCase))
                {
                    rt = entry;
                    break;
                }
            }
            return rt;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SlimDX.Direct3D10;
using SlimDX.D3DCompiler;
using SlimDX;
using SlimDX.DXGI;
using Device = SlimDX.Direct3D10.Device;
using Resource = SlimDX.Direct3D10.Resource;
using MapFlags = SlimDX.Direct3D10.MapFlags;
using System.IO;
using System.Drawing;

namespace SCMAPTools
{
    public class PreviewBuilder
    {
        //Direct X
        Device device;
        RenderTargetView renderTarget;
        Texture2D renderTargetTexture;
        
        //Effects
        Effect TerrainFX;
        Effect FrameFX;
        Effect WaterFX;

        //View
        Viewport viewport;
        Matrix viewMatrix;
        Matrix projectionMatrix;

        //Map Information
        Map scmapData;
        float mapScale;
        DataStream vertices;
        SlimDX.Direct3D10.Buffer vertexBuffer;

        //Global Shader Resources
        //These are stored here because they must be swapped in and out for various drawing calls
        ShaderResourceView normalMap;
        ShaderResourceView textureMapA;
        ShaderResourceView finalNormalMap;

        //Camera Data
        float xP; //X Position
        float yP; //Y position (This is the vertical height axis in FA)
        float zP; //Z Position 
        
        float cX; //Position camera is looking at (X coordinate)
        float cY; //Position camera is looking at (Y coordinate)  (corresponds to Z above)

        float uA = (float)-Math.PI; //Up angle
        float uE = 0.0f;            //Up elevation

        //Misc
        public float timeValue;  //Controls animation of water waves

        public PreviewBuilder(Map mapData)
        {
            scmapData = mapData;
            device = new Device(DriverType.Hardware, DeviceCreationFlags.Debug);

            mapScale = Math.Max(scmapData.Width, scmapData.Height);
            CreateVertexData();
            

            LoadTerrainAndFrameShaders();
            LoadWaterShader();

            timeValue = 0;
        }

        public SlimDX.Direct3D9.Texture CreatePreview(SlimDX.Direct3D9.Device device, int width, int height)
        {
            Bitmap bm = Internal_CreatePreview(width, height);

            MemoryStream ms = new MemoryStream();
            bm.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
            ms.Seek(0, SeekOrigin.Begin);
            return SlimDX.Direct3D9.Texture.FromStream(device, ms, bm.Width, bm.Height, 1, SlimDX.Direct3D9.Usage.None, SlimDX.Direct3D9.Format.A8R8G8B8, SlimDX.Direct3D9.Pool.Scratch, SlimDX.Direct3D9.Filter.None, SlimDX.Direct3D9.Filter.None, 0);
        }

        private Bitmap Internal_CreatePreview(int width, int height)
        {
            viewport = new Viewport(0, 0, width, height, 0.0f, 1.0f);
            SetUpCamera();
            CreateRenderTarget();

            //Set Shader Camera Parameters
            TerrainFX.GetVariableByName("ViewMatrix").AsMatrix().SetMatrix(viewMatrix);
            TerrainFX.GetVariableByName("ProjMatrix").AsMatrix().SetMatrix(projectionMatrix);
            TerrainFX.GetVariableByName("CameraPosition").AsVector().Set(new Vector3(xP, yP, zP));
            TerrainFX.GetVariableByName("CameraDirection").AsVector().Set(new Vector3(cX, 0, cY));

            //Generate Normal Texture
            Texture2D normalTexA = RenderNormalMap();

            //Final Normal Map Shader
            Texture2D finalNormalTex = RenderFinalNormalMap(normalTexA);

            //Render Terrain
            Texture2D terrTex = RenderTerrain(finalNormalTex);

            //Render Water
            RenderWater(terrTex);

            //Clean Up
            finalNormalTex.Dispose();
            normalTexA.Dispose();
            terrTex.Dispose();
            renderTarget.Dispose();

            Bitmap t = CreateFinalImage();
            renderTargetTexture.Dispose();
            return t;
        }
        Bitmap CreateFinalImage()
        {
            MemoryStream ms = new MemoryStream();
            Texture2D.ToStream(renderTargetTexture, ImageFileFormat.Png, ms);
            ms.Seek(0, SeekOrigin.Begin);

            Bitmap bm = new Bitmap(ms);
            for (int i = 0; i < bm.Width; i++)
            {
                for (int j = 0; j < bm.Height; j++)
                {
                    System.Drawing.Color c = bm.GetPixel(i, j);
                    System.Drawing.Color d = Color.FromArgb(255, c.R, c.G, c.B);
                    bm.SetPixel(i, j, d);
                }
            }
            return bm;
        }
        void SetUpCamera()
        {
            float camStartY = 0.0f;
            if (mapScale <= 257)
            {
                camStartY = 320;
            }
            else if (mapScale <= 513)
            {
                camStartY = 625;
            }
            else if (mapScale <= 1024)
            {
                camStartY = 1220;
            }
            else if (mapScale <= 2048)
            {
                camStartY = 2416;
            }

            xP = scmapData.Width / 2.0f;
            zP = scmapData.Height / 2.0f;
            yP = camStartY;
            cX = xP;
            cY = zP;


            float uX = (float)(Math.Sin(uA) * Math.Cos(uE));
            float uY = (float)(Math.Sin(uA) * Math.Sin(uE));
            float uZ = (float)Math.Cos(uA);

            viewMatrix = Matrix.LookAtRH(new Vector3(xP, yP, zP), new Vector3(cX, 0, cY), new Vector3(uX, uY, uZ));
            projectionMatrix = Matrix.PerspectiveFovRH((float)Math.PI / 4.0f, viewport.Width / viewport.Height, 0.00001f, 800.0f);
        }
        void LoadWaterShader()
        {
            WaterFX = Effect.FromMemory(device, Resources.water_fx, "fx_4_0", ShaderFlags.EnableBackwardsCompatibility, EffectFlags.None);

            WaterFX.GetVariableByName("SunDirection").AsVector().Set(scmapData.Water.SunDirection);
            WaterFX.GetVariableByName("SunColor").AsVector().Set(scmapData.Water.SunColor);
            WaterFX.GetVariableByName("SunShininess").AsScalar().Set(scmapData.Water.SunShininess);

            WaterFX.GetVariableByName("ViewportScaleOffset").AsVector().Set(new Vector4(0.5f, -0.5f, 0.5f, 0.5f));

            WaterFX.GetVariableByName("refractionScale").AsScalar().Set(scmapData.Water.RefractionScale);
            WaterFX.GetVariableByName("skyreflectionAmount").AsScalar().Set(scmapData.Water.SkyReflection);
            WaterFX.GetVariableByName("unitreflectionAmount").AsScalar().Set(scmapData.Water.UnitReflection);

            WaterFX.GetVariableByName("waterColor").AsVector().Set(scmapData.Water.SurfaceColor);
            WaterFX.GetVariableByName("waterLerp").AsVector().Set(scmapData.Water.ColorLerp);

            WaterFX.GetVariableByName("WaterElevation").AsScalar().Set(scmapData.Water.Elevation);

            WaterFX.GetVariableByName("waveCrestColor").AsVector().Set(new Vector3(1.0f, 1.0f, 1.0f));
            WaterFX.GetVariableByName("waveCrestThreshold").AsScalar().Set(1.0f);

            TextureLoader tl = new TextureLoader();
            for (int i = 0; i < 4; i++)
            {
                string mName = "normal" + (i + 1).ToString() + "Movement";
                string tName = "NormalMap" + (i).ToString();

                Texture2D tmp = tl.LoadTextureFromTexturesScd(scmapData.Water.WaveTextures[i].TexPath, device);
                ShaderResourceView srv = new ShaderResourceView(device, tmp);
                WaterFX.GetVariableByName(tName).AsResource().SetResource(srv);
                WaterFX.GetVariableByName(mName).AsVector().Set(scmapData.Water.WaveTextures[i].NormalMovement);
            }

            ShaderResourceView skyCube = tl.LoadTextureCubeFromTexturesScd(scmapData.TexPathSkyCubemap, device);
            WaterFX.GetVariableByName("SkyMap").AsResource().SetResource(skyCube);

            //Water Fresnel Sampler
            Texture2D fresnel = tl.LoadDdsTexture(Resources.FresnelTexture_dds, device);
            ShaderResourceView srvFresnel = new ShaderResourceView(device, fresnel);
            WaterFX.GetVariableByName("FresnelLookup").AsResource().SetResource(srvFresnel);

            //WaterMap
            Texture2D wm = tl.LoadDdsTexture(scmapData.WatermapTex, device);
            ShaderResourceView srvWM = new ShaderResourceView(device, wm);
            WaterFX.GetVariableByName("UtilityTextureC").AsResource().SetResource(srvWM);
        }
        void LoadTerrainAndFrameShaders()
        {
            //Load Shaders
            TerrainFX = Effect.FromMemory(device, Resources.terrain_fx, "fx_4_0", ShaderFlags.EnableBackwardsCompatibility, EffectFlags.None);
            FrameFX = Effect.FromMemory(device, Resources.frame_fx, "fx_4_0", ShaderFlags.EnableBackwardsCompatibility, EffectFlags.None);


            //Set Parameters

            //Stratum
            TextureLoader tl = new TextureLoader();
            for (int i = 0; i < 10; i++)
            {
                string sName = "";
                if (i == 0) { sName = "LowerAlbedo"; }
                else if (i == 9) { sName = "UpperAlbedo"; }
                else { sName = "Stratum" + (i - 1).ToString() + "Albedo"; }

                string nameA = sName + "Texture";
                string nameT = sName + "Tile";

                float tile = Utilities.TranslateTextureTileValue(scmapData.Layers[i].ScaleTexture);

                if (scmapData.Layers[i].PathTexture.Length > 0)
                {
                    Texture2D tmp = tl.LoadTextureFromEnvScd(scmapData.Layers[i].PathTexture, device);
                    ShaderResourceView srv = new ShaderResourceView(device, tmp);
                    TerrainFX.GetVariableByName(nameA).AsResource().SetResource(srv);
                    TerrainFX.GetVariableByName(nameT).AsVector().Set(new Vector4(tile, tile, 0.0f, 1.0f / tile));
                }
            }

            //Normals
            for (int i = 0; i < 9; i++)
            {
                string sName = "";
                if (i == 0) { sName = "LowerNormal"; }
                else { sName = "Stratum" + (i - 1).ToString() + "Normal"; }

                string nameA = sName + "Texture";
                string nameT = sName + "Tile";

                float tile = Utilities.TranslateTextureTileValue(scmapData.Layers[i].ScaleNormalmap);


                if (scmapData.Layers[i].PathNormalmap.Length > 0)
                {
                    Texture2D tmp2 = tl.LoadTextureFromEnvScd(scmapData.Layers[i].PathNormalmap, device);
                    ShaderResourceView srv = new ShaderResourceView(device, tmp2);
                    TerrainFX.GetVariableByName(nameA).AsResource().SetResource(srv);
                    TerrainFX.GetVariableByName(nameT).AsVector().Set(new Vector4(tile, tile, 0.0f, 1.0f / tile));
                }
            }

            TerrainFX.GetVariableByName("HeightScale").AsScalar().Set(scmapData.HeightScale);
            float ts = 1.0f / mapScale;
            TerrainFX.GetVariableByName("TerrainScale").AsVector().Set(new Vector4(ts, ts, 0.0f, 1.0f));

            //Texture Data
            Texture2D tm1 = tl.LoadDdsTexture(scmapData.TexturemapTex, device);
            textureMapA = new ShaderResourceView(device, tm1);
            TerrainFX.GetVariableByName("UtilityTextureA").AsResource().SetResource(textureMapA);

            Texture2D tm2 = tl.LoadDdsTexture(scmapData.TexturemapTex2, device);
            ShaderResourceView srvB = new ShaderResourceView(device, tm2);
            TerrainFX.GetVariableByName("UtilityTextureB").AsResource().SetResource(srvB);

            Texture2D wm = tl.LoadDdsTexture(scmapData.WatermapTex, device);
            ShaderResourceView srvC = new ShaderResourceView(device, wm);
            TerrainFX.GetVariableByName("UtilityTextureC").AsResource().SetResource(srvC);

            Texture2D nm = tl.LoadDdsTexture(scmapData.NormalmapTex, device);
            normalMap = new ShaderResourceView(device, nm);
            TerrainFX.GetVariableByName("NormalTexture").AsResource().SetResource(normalMap);

            //WaterRamp
            Texture2D wr = tl.LoadTextureFromTexturesScd(scmapData.Water.TexPathWaterRamp, device);
            ShaderResourceView srvWR = new ShaderResourceView(device, wr);
            TerrainFX.GetVariableByName("WaterRamp").AsResource().SetResource(srvWR);


            Texture2D ss = tl.LoadDdsTexture(Resources.ShadowTexture_dds, device);
            ShaderResourceView srvSS = new ShaderResourceView(device, ss);
            TerrainFX.GetVariableByName("ShadowTexture").AsResource().SetResource(srvSS);



            //Lighting
            TerrainFX.GetVariableByName("SunDirection").AsVector().Set(scmapData.SunDirection);
            TerrainFX.GetVariableByName("LightingMultiplier").AsScalar().Set(scmapData.LightingMultiplier);
            TerrainFX.GetVariableByName("SunAmbience").AsVector().Set(scmapData.SunAmbience);
            TerrainFX.GetVariableByName("SunColor").AsVector().Set(scmapData.SunColor);
            TerrainFX.GetVariableByName("SpecularColor").AsVector().Set(scmapData.SpecularColor);
            TerrainFX.GetVariableByName("ShadowsEnabled").AsScalar().Set(0);
            TerrainFX.GetVariableByName("ShadowFillColor").AsVector().Set(scmapData.ShadowFillColor);
            TerrainFX.GetVariableByName("ShadowMatrix").AsMatrix().SetMatrix(new Matrix());

            //Water
            TerrainFX.GetVariableByName("WaterElevation").AsScalar().Set(scmapData.Water.Elevation);
            TerrainFX.GetVariableByName("WaterElevationDeep").AsScalar().Set(scmapData.Water.ElevationDeep);
            TerrainFX.GetVariableByName("WaterElevationAbyss").AsScalar().Set(scmapData.Water.ElevationAbyss);

            //Viewport Settings
            TerrainFX.GetVariableByName("ViewportScale").AsVector().Set(new Vector2(0.5f, -0.5f));
            TerrainFX.GetVariableByName("ViewportOffset").AsVector().Set(new Vector2(0.5f, 0.5f));

            TerrainFX.GetVariableByName("e_x").AsVector().Set(new Vector2(ts, 0.0f));
            TerrainFX.GetVariableByName("e_y").AsVector().Set(new Vector2(0.0f, ts));
            TerrainFX.GetVariableByName("size_source").AsVector().Set(new Vector2(mapScale, mapScale));

            //Bicubic Sampler
            Texture2D bicubic = tl.LoadDdsTexture(Resources.BicubicRamp_dds, device);
            ShaderResourceView srvBicubic = new ShaderResourceView(device, bicubic);
            TerrainFX.GetVariableByName("BiCubicLookup").AsResource().SetResource(srvBicubic);

            TerrainFX.GetVariableByName("NormalMapScale").AsVector().Set(new Vector4(1.0f, 1.0f, 0.0f, 0.0f));
            TerrainFX.GetVariableByName("NormalMapOffset").AsVector().Set(new Vector4(0.0f, 0.0f, 0.0f, 0.0f));

        }
        void CreateVertexData()
        {
            float w = 1.0f;
            //Create Vertices
            vertices = new DataStream(((scmapData.Width + 1) * (scmapData.Height + 1) - 1) * 16 * 2, true, true);
            for (int x = 0; x < scmapData.Width; x++)
            {
                for (int z = 0; z <= scmapData.Height; z++)
                {
                    vertices.Write(new Vector4(x, scmapData.GetHeight(x, z), z, w));
                    vertices.Write(new Vector4(x + 1, scmapData.GetHeight(x + 1, z), z, w));
                }
                vertices.Write(new Vector4(x + 1, scmapData.GetHeight(x + 1, scmapData.Height), scmapData.Height, w));
                vertices.Write(new Vector4(x + 1, scmapData.GetHeight(x + 1, 0), 0, w));
            }

            vertices.Position = 0;
            vertexBuffer = new SlimDX.Direct3D10.Buffer(device, vertices, (int)vertices.Length, ResourceUsage.Default, BindFlags.VertexBuffer, CpuAccessFlags.None, ResourceOptionFlags.None);
        }
        void CreateRenderTarget()
        {
            Texture2DDescription textureDesc = new Texture2DDescription();
            textureDesc.Width = viewport.Width;
            textureDesc.Height = viewport.Height;
            textureDesc.MipLevels = 1;
            textureDesc.ArraySize = 1;
            textureDesc.Format = Format.R8G8B8A8_UNorm;
            textureDesc.SampleDescription = new SampleDescription(1,0);
            textureDesc.Usage = ResourceUsage.Default;
            textureDesc.BindFlags = BindFlags.RenderTarget | BindFlags.ShaderResource;
            textureDesc.CpuAccessFlags = CpuAccessFlags.None;
            textureDesc.OptionFlags = ResourceOptionFlags.None;
            
            renderTargetTexture = new Texture2D(device, textureDesc);

            renderTarget = new RenderTargetView(device, renderTargetTexture);
        }
        Texture2D RenderNormalMap()
        {
            device.ClearAllObjects();

            vertices.Position = 0;

            Texture2DDescription textureDesc = new Texture2DDescription();
            textureDesc.Width = viewport.Width;
            textureDesc.Height = viewport.Height;
            textureDesc.MipLevels = 1;
            textureDesc.ArraySize = 1;
            textureDesc.Format = Format.R8G8B8A8_UNorm;
            textureDesc.SampleDescription = new SampleDescription(1, 0);
            textureDesc.Usage = ResourceUsage.Default;
            textureDesc.BindFlags = BindFlags.RenderTarget | BindFlags.ShaderResource;
            textureDesc.CpuAccessFlags = CpuAccessFlags.None;
            textureDesc.OptionFlags = ResourceOptionFlags.None;

            Texture2D normalTex = new Texture2D(device, textureDesc);

            RenderTargetViewDescription rtDesc = new RenderTargetViewDescription();
            rtDesc.Format = textureDesc.Format;
            rtDesc.Dimension = RenderTargetViewDimension.Texture2D;
            rtDesc.MipSlice = 0;

            RenderTargetView renderTargetNormal = new RenderTargetView(device, normalTex, rtDesc);

            TerrainFX.GetVariableByName("UtilityTextureA").AsResource().SetResource(textureMapA);

            EffectTechnique techniqueBasis = TerrainFX.GetTechniqueByName("TTerrainBasisBiCubic");
            EffectPass passBasis = techniqueBasis.GetPassByIndex(0);

            EffectTechnique techniqueNormals = TerrainFX.GetTechniqueByName("TTerrainNormalsXP");
            EffectPass passNormals = techniqueNormals.GetPassByIndex(0);

            var layoutA = new InputLayout(device, passNormals.Description.Signature, new[] {
                new InputElement("POSITION", 0, Format.R32G32B32A32_Float, 0, 0)});

            var layoutB = new InputLayout(device, passBasis.Description.Signature, new[] {
                new InputElement("POSITION", 0, Format.R32G32B32A32_Float, 0, 0)});

            device.OutputMerger.SetTargets(renderTargetNormal);
            device.Rasterizer.SetViewports(viewport);
            device.ClearRenderTargetView(renderTargetNormal, System.Drawing.Color.Black);

            device.InputAssembler.SetInputLayout(layoutA);
            device.InputAssembler.SetPrimitiveTopology(PrimitiveTopology.TriangleStrip);
            device.InputAssembler.SetVertexBuffers(0, new VertexBufferBinding(vertexBuffer, 16, 0));

            for (int i = 0; i < techniqueNormals.Description.PassCount; i++)
            {
                passNormals.Apply();
                device.Draw((int)vertices.Length / 16, 0);
            }

            TerrainFX.GetVariableByName("UtilityTextureA").AsResource().SetResource(normalMap);
            device.InputAssembler.SetInputLayout(layoutB);

            for (int i = 0; i < techniqueBasis.Description.PassCount; i++)
            {
                passBasis.Apply();
                device.Draw((int)vertices.Length / 16, 0);
            }

            layoutA.Dispose();
            layoutB.Dispose();
            renderTargetNormal.Dispose();

            return normalTex;
        }
        Texture2D RenderFinalNormalMap(Texture2D prelimNormalMap)
        {
            device.ClearAllObjects();

            //Create Vertices
            DataStream texVertices = new DataStream(4 * 32, true, true);
            float w = 1.0f;
            texVertices.Write(new Vector4(-0.5f, -0.5f, w, w));
            texVertices.Write(new Vector2(0, 0));
            texVertices.Write(new Vector2(0, 0));
            texVertices.Write(new Vector4(viewport.Width - 0.5f, -0.5f, w, w));
            texVertices.Write(new Vector2(1, 0));
            texVertices.Write(new Vector2(1, 0));
            texVertices.Write(new Vector4(-0.5f, viewport.Height - 0.5f, w, w));
            texVertices.Write(new Vector2(0, 1));
            texVertices.Write(new Vector2(0, 1));
            texVertices.Write(new Vector4(viewport.Width - 0.5f, viewport.Height - 0.5f, w, w));
            texVertices.Write(new Vector2(1, 1));
            texVertices.Write(new Vector2(1, 1));
            texVertices.Position = 0;

            //Vertex Buffer
            var vertexBufferF = new SlimDX.Direct3D10.Buffer(device, texVertices, (int)texVertices.Length, ResourceUsage.Default, BindFlags.VertexBuffer, CpuAccessFlags.None, ResourceOptionFlags.None);

            //Shader Resources
            ShaderResourceView normalSRV = new ShaderResourceView(device, prelimNormalMap);

            //Render Target
            Texture2DDescription textureDesc2 = new Texture2DDescription();
            textureDesc2.Width = viewport.Width;
            textureDesc2.Height = viewport.Height;
            textureDesc2.MipLevels = 1;
            textureDesc2.ArraySize = 1;
            textureDesc2.Format = Format.R8G8B8A8_UNorm;
            textureDesc2.SampleDescription = new SampleDescription(1, 0);
            textureDesc2.Usage = ResourceUsage.Default;
            textureDesc2.BindFlags = BindFlags.RenderTarget | BindFlags.ShaderResource;
            textureDesc2.CpuAccessFlags = CpuAccessFlags.None;
            textureDesc2.OptionFlags = ResourceOptionFlags.None;

            Texture2D finalNormalTex = new Texture2D(device, textureDesc2);

            RenderTargetViewDescription rtDesc2 = new RenderTargetViewDescription();
            rtDesc2.Format = textureDesc2.Format;
            rtDesc2.Dimension = RenderTargetViewDimension.Texture2D;
            rtDesc2.MipSlice = 0;

            RenderTargetView renderTargetFinalNormal = new RenderTargetView(device, finalNormalTex, rtDesc2);

            EffectTechnique techniqueFrameBasis = FrameFX.GetTechniqueByName("TCreateBasis");
            EffectPass passFrameBasis = techniqueFrameBasis.GetPassByIndex(0);

            var layoutC = new InputLayout(device, passFrameBasis.Description.Signature, new[] {
                new InputElement("POSITION", 0, Format.R32G32B32A32_Float, 0, 0),
                new InputElement("TEXCOORD", 0, Format.R32G32_Float, 16, 0),
                new InputElement("TEXCOORD", 1, Format.R32G32_Float, 24, 0)});

            //configure Device
            device.OutputMerger.SetTargets(renderTargetFinalNormal);
            device.Rasterizer.SetViewports(viewport);

            device.ClearRenderTargetView(renderTargetFinalNormal, System.Drawing.Color.Black);

            device.InputAssembler.SetInputLayout(layoutC);
            device.InputAssembler.SetPrimitiveTopology(PrimitiveTopology.TriangleStrip);
            device.InputAssembler.SetVertexBuffers(0, new VertexBufferBinding(vertexBufferF, 32, 0));

            //Set Shader Resources
            FrameFX.GetVariableByName("FrameTexture1").AsResource().SetResource(normalSRV);
            FrameFX.GetVariableByName("framewidth").AsScalar().Set(viewport.Width);
            FrameFX.GetVariableByName("frameheight").AsScalar().Set(viewport.Height);
            FrameFX.GetVariableByName("viewport").AsVector().Set(new Vector4(0, 0, viewport.Width, viewport.Height));

            for (int i = 0; i < techniqueFrameBasis.Description.PassCount; i++)
            {
                passFrameBasis.Apply();
                device.Draw((int)texVertices.Length / 32, 0);
            }

            normalSRV.Dispose();
            texVertices.Close();
            texVertices.Dispose();
            vertexBufferF.Dispose();
            layoutC.Dispose();
            renderTargetFinalNormal.Dispose();
            device.ClearAllObjects();

            return finalNormalTex;
        }
        Texture2D RenderTerrain(Texture2D finalNormalTex)
        {
            device.ClearAllObjects();

            finalNormalMap = new ShaderResourceView(device, finalNormalTex);

            //Set Terrain Shader Variables
            TerrainFX.GetVariableByName("UtilityTextureA").AsResource().SetResource(textureMapA);
            TerrainFX.GetVariableByName("NormalTexture").AsResource().SetResource(finalNormalMap);

            EffectTechnique technique = TerrainFX.GetTechniqueByName(scmapData.TerrainShader);
            EffectPass pass = technique.GetPassByIndex(0);

            var terrainLayout = new InputLayout(device, pass.Description.Signature, new[] {
                new InputElement("POSITION", 0, Format.R32G32B32A32_Float, 0, 0)});

            //configure Device
            device.OutputMerger.SetTargets(renderTarget);
            device.Rasterizer.SetViewports(viewport);

            device.ClearRenderTargetView(renderTarget, System.Drawing.Color.Black);

            device.InputAssembler.SetInputLayout(terrainLayout);
            device.InputAssembler.SetPrimitiveTopology(PrimitiveTopology.TriangleStrip);
            device.InputAssembler.SetVertexBuffers(0, new VertexBufferBinding(vertexBuffer, 16, 0));



            // draw the triangles
            for (int i = 0; i < technique.Description.PassCount; i++)
            {
                pass.Apply();
                device.Draw((int)vertices.Length / 16, 0);
            }



            Texture2DDescription textureDesc = new Texture2DDescription();
            textureDesc.Width = viewport.Width;
            textureDesc.Height = viewport.Height;
            textureDesc.MipLevels = 1;
            textureDesc.ArraySize = 1;
            textureDesc.Format = Format.R8G8B8A8_UNorm;
            textureDesc.SampleDescription = new SampleDescription(1, 0);
            textureDesc.Usage = ResourceUsage.Default;
            textureDesc.BindFlags = BindFlags.RenderTarget | BindFlags.ShaderResource;
            textureDesc.CpuAccessFlags = CpuAccessFlags.None;
            textureDesc.OptionFlags = ResourceOptionFlags.None;

            Texture2D TerrainTexTarget = new Texture2D(device, textureDesc);
            RenderTargetView terrRenderTarget = new RenderTargetView(device, TerrainTexTarget);

            device.OutputMerger.SetTargets(terrRenderTarget);
            device.Rasterizer.SetViewports(viewport);
            device.ClearRenderTargetView(terrRenderTarget, System.Drawing.Color.Black);

            // draw the triangles
            for (int i = 0; i < technique.Description.PassCount; i++)
            {
                pass.Apply();
                device.Draw((int)vertices.Length / 16, 0);
            }

            terrRenderTarget.Dispose();
            terrainLayout.Dispose();
            finalNormalMap.Dispose();

            return TerrainTexTarget;
        }
        void RenderWater(Texture2D terrainTex)
        {
            //Create Vertices
            DataStream texVertices = new DataStream(6 * 20, true, true);
            texVertices.Write(new Vector3(0.0f, scmapData.Water.Elevation, 0.0f));
            texVertices.Write(new Vector2(0, 0));
            texVertices.Write(new Vector3(0.0f, scmapData.Water.Elevation, scmapData.Height));
            texVertices.Write(new Vector2(0, 1));
            texVertices.Write(new Vector3(scmapData.Width, scmapData.Water.Elevation, 0.0f));
            texVertices.Write(new Vector2(1, 0));

            texVertices.Write(new Vector3(0.0f, scmapData.Water.Elevation, scmapData.Height));
            texVertices.Write(new Vector2(0, 1));
            texVertices.Write(new Vector3(scmapData.Width, scmapData.Water.Elevation, scmapData.Height));
            texVertices.Write(new Vector2(1, 1));
            texVertices.Write(new Vector3(scmapData.Width, scmapData.Water.Elevation, 0.0f));
            texVertices.Write(new Vector2(1, 0));




            texVertices.Position = 0;

            //Vertex Buffer
            var vertexBufferW = new SlimDX.Direct3D10.Buffer(device, texVertices, (int)texVertices.Length, ResourceUsage.Default, BindFlags.VertexBuffer, CpuAccessFlags.None, ResourceOptionFlags.None);

            //Shader Effect
            EffectTechnique techniqueWaterHF = WaterFX.GetTechniqueByName("Water_HighFidelity");
            EffectPass passWaterHF = techniqueWaterHF.GetPassByIndex(0);

            var layoutD = new InputLayout(device, passWaterHF.Description.Signature, new[] {
                new InputElement("POSITION", 0, Format.R32G32B32_Float, 0, 0),
                new InputElement("TEXCOORD", 0, Format.R32G32_Float, 12, 0)});

            //Configure Device for Rendering
            device.OutputMerger.SetTargets(renderTarget);

            device.InputAssembler.SetInputLayout(layoutD);
            device.InputAssembler.SetPrimitiveTopology(PrimitiveTopology.TriangleList);
            device.InputAssembler.SetVertexBuffers(0, new VertexBufferBinding(vertexBufferW, 20, 0));

            //Set Shader Resources
            ShaderResourceView refractionSRV = new ShaderResourceView(device, terrainTex);
            WaterFX.GetVariableByName("RefractionMap").AsResource().SetResource(refractionSRV);

            //Matrix waterProj = Matrix.PerspectiveFovRH(0.82121f, viewport.Width / viewport.Height, 0.000001f, 10000.0f);

            WaterFX.GetVariableByName("Projection").AsMatrix().SetMatrix(projectionMatrix);
            WaterFX.GetVariableByName("WorldToView").AsMatrix().SetMatrix(viewMatrix);

            WaterFX.GetVariableByName("Time").AsScalar().Set(timeValue);
            WaterFX.GetVariableByName("ViewPosition").AsVector().Set(new Vector3(xP, yP, zP));


            for (int i = 0; i < techniqueWaterHF.Description.PassCount; i++)
            {
                passWaterHF.Apply();
                device.Draw((int)texVertices.Length / 20, 0);
            }

            layoutD.Dispose();
            refractionSRV.Dispose();
            vertexBufferW.Dispose();
        }
    }
}

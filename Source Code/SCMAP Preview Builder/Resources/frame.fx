
#define technique technique10
#define DIRECT3D10 1

// shader 4.0 mapping
#define vs_1_1 vs_4_0
#define vs_1_3 vs_4_0
#define vs_1_4 vs_4_0
#define vs_2_0 vs_4_0
#define vs_3_0 vs_4_0
#define ps_1_1 ps_4_0
#define ps_1_3 ps_4_0
#define ps_1_4 ps_4_0
#define ps_2_0 ps_4_0
#define ps_2_a ps_4_0
#define ps_2_b ps_4_0
#define ps_3_0 ps_4_0

// workarounds for backwords compatbility issues in new d3d10 compiler
#define MipFilter Filter
#define MinFilter Filter
#define MagFilter Filter
#define NONE MIN_MAG_MIP_POINT
#define LINEAR MIN_MAG_MIP_LINEAR
#define POINT MIN_MAG_MIP_POINT

#define FIXED_FUNC_VS compile vs_4_0 FixedFuncVS()
#define FIXED_FUNC_BLOOM_VS compile vs_4_0 FixedFuncBloomVS()
#define FIXED_FUNC_PS compile ps_4_0 FixedFuncPS()

// state
#define AlphaState(p) SetBlendState( p, float4(0,0,0,0), 0xFFFFFFFF );
#define DepthState(p) SetDepthStencilState( p, 0x03 );
#define RasterizerState(p) SetRasterizerState( p );

// decals
#define decalDepthOffset (-0.00001)

// alpha test workaround for D3D10
#define d3d_LessEqual 0
#define d3d_NotEqual 1
#define d3d_Equal 2
#define d3d_Greater 3

// engine was not written for D3D10
#define CompatSwizzle(c) c.rgba = c.bgra

void AlphaTestD3D10( float inputAlpha, int alphaFunc, int alphaRef )
{
	if( alphaFunc == d3d_LessEqual )
	{
		if( inputAlpha > alphaRef/255.0 )
			discard; 
	}
	else if( alphaFunc == d3d_NotEqual )
	{
		if( inputAlpha == alphaRef/255.0 )
			discard;
	}
	else if( alphaFunc == d3d_Equal )
	{
		if( inputAlpha != alphaRef/255.0 )
			discard;
	}
	else if( alphaFunc == d3d_Greater )
	{
		if( inputAlpha <= alphaRef/255.0 )
			discard;
	}
}

//
// Blend States
//
BlendState AlphaBlend_Disable
{
	BlendEnable[0] = false;	
	
    RenderTargetWriteMask[0] = 0x0F;
	SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Default_Write_RGB
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x07;
    
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Default_Write_A
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x08;
    
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_SrcAlpha_InvSrcAlpha_Write_RGBA
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x0F;
    SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_SrcAlpha_One_Write_RGBA
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x0F;
    SrcBlend = SRC_ALPHA;
    DestBlend = ONE;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_SrcAlpha_One_Write_RGB
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x07;
    SrcBlend = SRC_ALPHA;
    DestBlend = ONE;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_SrcAlpha_One
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x07;
    SrcBlend = SRC_ALPHA;
    DestBlend = ONE;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_SrcAlpha_InvSrcAlpha_Write_RGB
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x07;
    SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_SrcAlpha_InvSrcAlpha_Write_RG
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x03;
    SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_SrcAlpha_InvSrcAlpha_Write_RBA
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x0D;
    SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_InvSrcAlpha_Write_RGB
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x07;
    SrcBlend = ONE;
    DestBlend = INV_SRC_ALPHA;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_InvSrcAlpha_Write_RGBA
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x0F;
    SrcBlend = ONE;
    DestBlend = INV_SRC_ALPHA;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_InvSrcAlpha
{
    BlendEnable[0] = true;	
    SrcBlend = ONE;
    DestBlend = INV_SRC_ALPHA;
    
    RenderTargetWriteMask[0] = 0x0F;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Zero_InvSrcColor
{
    BlendEnable[0] = true;	
    SrcBlend = ZERO;
    DestBlend = INV_SRC_COLOR;
    
    RenderTargetWriteMask[0] = 0x07;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Zero_InvSrcColor_Write_RGBA
{
    BlendEnable[0] = true;	
    SrcBlend = ZERO;
    DestBlend = INV_SRC_COLOR;
    
    RenderTargetWriteMask[0] = 0x0F;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Zero_SrcColor_Write_RGB
{
    BlendEnable[0] = true;	
    SrcBlend = ZERO;
    DestBlend = SRC_COLOR;
    RenderTargetWriteMask[0] = 0x07;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_SrcAlpha_InvSrcAlpha_Write_A
{
    BlendEnable[0] = true;	
    RenderTargetWriteMask[0] = 0x08;
    SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA;

	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_InvDestColor_InvSrcColor
{
    BlendEnable[0] = true;	
    SrcBlend = INV_DEST_COLOR;
    DestBlend = INV_SRC_COLOR;
    
    RenderTargetWriteMask[0] = 0x07;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_InvDestColor_InvSrcColor_Write_RGBA
{
    BlendEnable[0] = true;	
    SrcBlend = INV_DEST_COLOR;
    DestBlend = INV_SRC_COLOR;
    
    RenderTargetWriteMask[0] = 0x0F;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_Zero
{
    BlendEnable[0] = true;
	SrcBlend = ONE;
    DestBlend = ZERO;
    
    RenderTargetWriteMask[0] = 0x0F;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_One
{
    RenderTargetWriteMask[0] = 0x07;
    
    BlendEnable[0] = true;
	SrcBlend = ONE;
    DestBlend = ONE;
	BlendOp = ADD;
    
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_One_Write_RGB
{
    BlendEnable[0] = true;
	SrcBlend = ONE;
    DestBlend = ONE;
    RenderTargetWriteMask[0] = 0x07;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_One_Write_RGBA
{
    BlendEnable[0] = true;
	SrcBlend = ONE;
    DestBlend = ONE;
    RenderTargetWriteMask[0] = 0x0F;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_One_Write_A
{
    BlendEnable[0] = true;
	SrcBlend = ONE;
    DestBlend = ONE;
    RenderTargetWriteMask[0] = 0x08;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_One_Zero_Write_A
{
	BlendEnable[0] = true;
	SrcBlend = ONE;
    DestBlend = ZERO;
    RenderTargetWriteMask[0] = 0x08;
    
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Write_A
{
    RenderTargetWriteMask[0] = 0x08;
	BlendEnable[0] = true;
		   
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Write_RGB
{
    RenderTargetWriteMask[0] = 0x07;
	BlendEnable[0] = true;
		   
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Write_RGBA
{
    RenderTargetWriteMask[0] = 0x0F;
	BlendEnable[0] = true;
		   
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Disable_Write_A
{
    RenderTargetWriteMask[0] = 0x08;
	BlendEnable[0] = false;
		   
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Disable_Write_RG
{
    RenderTargetWriteMask[0] = 0x03;
	BlendEnable[0] = false;
		   
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Disable_Write_BA
{
    RenderTargetWriteMask[0] = 0x0C;
	BlendEnable[0] = false;
		   
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Disable_Write_RGB
{
    RenderTargetWriteMask[0] = 0x07;
	BlendEnable[0] = false;
		   
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Disable_Write_RGBA
{
    RenderTargetWriteMask[0] = 0x0F;
	BlendEnable[0] = false;
		   
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

BlendState AlphaBlend_Disable_Write_None
{
    RenderTargetWriteMask[0] = 0x00;
	BlendEnable[0] = false;	   
	
    SrcBlend = ONE;
	DestBlend = ZERO;
	BlendOp = ADD;
	SrcBlendAlpha = ONE;
	DestBlendAlpha = ZERO;
	BlendOpAlpha = ADD;
};

//
// DepthStencilStates
//

DepthStencilState Depth_Disable
{
	DepthEnable = FALSE;
	
	DepthWriteMask = ALL;
	DepthFunc = LESS_EQUAL;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Enable
{
	DepthEnable = TRUE;
	
	DepthWriteMask = ALL;
	DepthFunc = LESS_EQUAL;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Always
{
	DepthFunc = ALWAYS;
	
	DepthEnable = TRUE;
	DepthWriteMask = ALL;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Enable_Greater
{
	DepthEnable = TRUE;
	DepthFunc = GREATER;
	
	DepthWriteMask = ALL;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Enable_Less
{
	DepthEnable = TRUE;
	DepthFunc = LESS;
	
	DepthWriteMask = ALL;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Enable_Greater_Write_None
{
	DepthEnable = TRUE;
	DepthWriteMask = 0;
	DepthFunc = GREATER;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Enable_Less_Write_None
{
	DepthEnable = TRUE;
	DepthWriteMask = 0;
	DepthFunc = LESS;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Enable_LessEqual_Write_None
{
	DepthEnable = TRUE;
	DepthWriteMask = 0;
	DepthFunc = LESS_EQUAL;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Enable_Always_Write_None
{
	DepthEnable = TRUE;
	DepthWriteMask = 0;
	DepthFunc = ALWAYS;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Disable_Write_None
{
	DepthEnable = FALSE;
	DepthWriteMask = 0;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0;
	StencilWriteMask = 0;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = ALWAYS;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_Occlude
{
	StencilEnable = TRUE;
	StencilReadMask = 0x01;
	StencilWriteMask = 0x01;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = REPLACE;
	FrontFaceStencilFunc = ALWAYS;
	
	DepthEnable = TRUE;
	DepthWriteMask = ALL;
	DepthFunc = LESS_EQUAL;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
};

DepthStencilState Depth_SilhouetteP0
{
	DepthEnable = FALSE;
	DepthWriteMask = 0;
	StencilEnable = TRUE;
	StencilReadMask = 0x02;
	StencilWriteMask = 0x02;
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = REPLACE;
	FrontFaceStencilPass = REPLACE;
	FrontFaceStencilFunc = ALWAYS;
	
	DepthFunc = LESS_EQUAL;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
};

DepthStencilState Depth_SilhouetteP1
{
	DepthEnable = TRUE;
	DepthWriteMask = 0;
	StencilEnable = TRUE;
	StencilReadMask = 0x03;
	StencilWriteMask = 0x0F;
	// TODO: work out how to do stencil ref (0x03)
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = ZERO;
	FrontFaceStencilFunc = EQUAL;
	
	DepthFunc = LESS_EQUAL;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
};

DepthStencilState Depth_TSilhouette
{
	DepthEnable = FALSE;
	DepthWriteMask = 0;
	StencilEnable = TRUE;
	StencilReadMask = 0xFF;
	StencilWriteMask = 0xFF;
	// TODO: work out how to do stencil ref (0x03)
	FrontFaceStencilFail = KEEP;
	FrontFaceStencilDepthFail = KEEP;
	FrontFaceStencilPass = KEEP;
	FrontFaceStencilFunc = EQUAL;
	
	DepthFunc = LESS_EQUAL;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
};

DepthStencilState Depth_TCommand
{
	DepthEnable = FALSE;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0x0F;
	StencilWriteMask = 0x0F;
	// TODO: work out how to do stencil ref (0x01)
	FrontFaceStencilFail = REPLACE;
	FrontFaceStencilPass = REPLACE;
	FrontFaceStencilFunc = NOT_EQUAL;
	
	FrontFaceStencilDepthFail = KEEP;
	DepthWriteMask = ALL;
	DepthFunc = LESS_EQUAL;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

DepthStencilState Depth_TCommandOther
{
	DepthEnable = FALSE;

	StencilEnable = FALSE;
#if 0
	StencilReadMask = 0x0;
	StencilWriteMask = 0x0;
	// TODO: work out how to do stencil ref (0x02)
	FrontFaceStencilFail = REPLACE;
	FrontFaceStencilPass = REPLACE;
	FrontFaceStencilFunc = NOT_EQUAL;
	
	FrontFaceStencilDepthFail = KEEP;
	DepthWriteMask = ALL;
	DepthFunc = LESS_EQUAL;
	BackFaceStencilFail = KEEP;
	BackFaceStencilDepthFail = KEEP;
	BackFaceStencilPass = KEEP;
	BackFaceStencilFunc = ALWAYS;
#endif
};

//
// RasterizerStates
//

RasterizerState Rasterizer_Cull_CCW
{
	FillMode = SOLID;
	CullMode = BACK;
	FrontCounterClockwise = FALSE;
	DepthBias = 0;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_CCW_Bias_Neg02
{
	FillMode = SOLID;
	CullMode = None;
	FrontCounterClockwise = FALSE;
	DepthBias = -0.02;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_CCW_Bias_Neg001
{
	FillMode = SOLID;
	CullMode = BACK;
	FrontCounterClockwise = FALSE;
	DepthBias = -0.001;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_None_Bias_Neg001
{
	FillMode = SOLID;
	CullMode = None;
	FrontCounterClockwise = FALSE;
	// shanond: Why is this necessary?
	DepthBias = -10000;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Bias_Decal
{
	FillMode = SOLID;
	CullMode = None;
	FrontCounterClockwise = FALSE;
	DepthBias = decalDepthOffset;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_CW
{
	FillMode = SOLID;
	CullMode = FRONT;
	FrontCounterClockwise = FALSE;
	DepthBias = 0;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_None
{
	FillMode = SOLID;
	CullMode = None;
	FrontCounterClockwise = FALSE;
	DepthBias = 0;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Wire
{
	FillMode = WIREFRAME;
	CullMode = BACK;
	FrontCounterClockwise = FALSE;
	DepthBias = 0;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Solid
{
	FillMode = SOLID;
	CullMode = BACK;
	FrontCounterClockwise = FALSE;
	DepthBias = 0;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_CCW_Fill_Wire
{
	FillMode = WIREFRAME;
	CullMode = BACK;
	FrontCounterClockwise = FALSE;
	DepthBias = 0;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_CCW_Bias_Neg02_Fill_Wire
{
	FillMode = WIREFRAME;
	CullMode = BACK;
	FrontCounterClockwise = FALSE;
	DepthBias = -0.02;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Bias_Decal_Fill_Wire
{
	FillMode = WIREFRAME;
	CullMode = BACK;
	FrontCounterClockwise = FALSE;
	DepthBias = decalDepthOffset;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_CW_Fill_Wire
{
	FillMode = WIREFRAME;
	CullMode = FRONT;
	FrontCounterClockwise = FALSE;
	DepthBias = 0;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

RasterizerState Rasterizer_Cull_None_Fill_Wire
{
	FillMode = WIREFRAME;
	CullMode = None;
	FrontCounterClockwise = FALSE;
	DepthBias = 0;
	DepthBiasClamp = 0;
	SlopeScaledDepthBias = 0;
	DepthClipEnable = FALSE;
	ScissorEnable = FALSE;
	MultisampleEnable = TRUE;
	AntialiasedLineEnable = FALSE;
};

//
// End
//

// variables global to this effect.
float4x4	ObjectToWorld;
float4x4	WorldToView;
float4x4	Projection;
texture     FrameTexture1;
texture     FrameTexture2;
texture     FrameTexture3;
texture     FrameTexture4;
int         useStrategicOverlay = 0;
float       mapElevation = 0.0f;

///
float       DissolveOffset = 0.5;

///
float BlurKernel[] = { -3, -2, -1,  0,  1,  2, 3, };
float BlurWeight[] = { 0.102734, 0.120985, 0.176033, 0.199471, 0.176033, 0.120985, 0.102734, };

float		BlurScale;
float		GlowCopyScale;
float       GlowCopyAdd;

float4      silhouetteColor = float4( 0, 0, 1, 1 );
float4		rangeColor = float4(0.2,0.2,0.2,0.2);

float		framewidth;
float		frameheight;
float4		viewport;

//============================================================================
//
//    Frame buffer shaders
//
//============================================================================



sampler2D FrameSampler1 = sampler_state
{
    Texture = (FrameTexture1);
	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

sampler2D FrameSamplerLinear1 = sampler_state
{
    Texture = (FrameTexture1);
	MipFilter = NONE;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

sampler2D FrameSampler2 = sampler_state
{
    Texture = (FrameTexture2);
	MipFilter = NONE;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

sampler2D FrameSamplerWrap2 = sampler_state
{
    Texture = (FrameTexture2);
    MipFilter = NONE;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};

sampler2D FrameSampler3 = sampler_state
{
    Texture = (FrameTexture3);
	MipFilter = NONE;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

sampler2D FrameSampler4 = sampler_state
{
    Texture = (FrameTexture4);
	MipFilter = NONE;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

sampler2D FrameSamplerWrap4 = sampler_state
{
    Texture = (FrameTexture4);
    MipFilter = NONE;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};

struct VS_IN
{
    float4 Pos   : POSITION;    
    float2 Tex1  : TEXCOORD0;
};

struct VS_OUT
{
    float4 Pos   : POSITION;    
    float2 Tex1  : TEXCOORD0;
    float2 Tex2  : TEXCOORD1; 
};


float2 FixedFuncTexCoord( float2 rval)
{
	float2 lval;
	lval.x = ( rval.x * viewport.z + viewport.x ) / framewidth;
	lval.y = ( rval.y * viewport.w + viewport.y ) / frameheight;
	return lval;
}

VS_OUT FixedFuncVS( VS_IN In )
{
    VS_OUT Out = (VS_OUT)0;

	float2 position = ( In.Pos.xy + float2(0.5,0.5) ) / float2(framewidth,frameheight);
	position = float2( 2 * position.x - 1, 1 - 2 * position.y );
	
	Out.Pos = float4(position.xy,In.Pos.z,In.Pos.w);    		
    Out.Tex1 = FixedFuncTexCoord(In.Tex1);
    Out.Tex2 = FixedFuncTexCoord(In.Tex1);

    return Out;
}

VS_OUT FixedFuncBloomVS( VS_IN In )
{
    VS_OUT Out = (VS_OUT)0;

	float2 position = ( In.Pos.xy + float2(0.5,0.5) ) / float2(framewidth,frameheight);
	position = float2( 2 * position.x - 1, 1 - 2 * position.y );
	
	Out.Pos = float4(position.xy,In.Pos.z,In.Pos.w);    		
    Out.Tex1 = In.Tex1;
    Out.Tex2 = In.Tex1;

    return Out;
}

float4 FixedPS(
	float4 Pos	 : POSITION,
    float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR
{
	return tex2D(FrameSampler1, Tex1);
}

float4 BackgroundPS( 
	float4 Pos	 : POSITION,
	float2 Tex1 : TEXCOORD0,
	float2 Tex2  : TEXCOORD1,
	uniform bool alphaTestEnable, 
    uniform int alphaFunc, 
    uniform int alphaRef 
	) : COLOR0
{
    float3 color = tex2D( FrameSampler1, Tex1).rgb;
    float  dissolve = tex2D( FrameSamplerWrap2, 8 * Tex1).a;
    
    float alpha = saturate( dissolve + DissolveOffset);
#ifdef DIRECT3D10
	if( alphaTestEnable )
		AlphaTestD3D10( alpha, alphaFunc, alphaRef );
#endif
    return  float4( color, alpha );
}

float4 PunchoutPS(
	float4 Pos	 : POSITION,
	float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR0
{
    return float4(0,0,0,1);
}

float4 SilhouettePS(
	float4 Pos	 : POSITION,
	float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR0
{
    return silhouetteColor;
}

float4 RangePS(
	float4 Pos	 : POSITION,
	float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1,
    uniform float4 color
) : COLOR0
{
	return color;
}

float4 VisionPS(
	float4 Pos	 : POSITION,
	float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1,
    uniform float factor
) : COLOR0
{
	return float4(0,0,0,factor);
}

struct STRATEGIC_VERTEX
{
    float4 position : POSITION0;
    float2 texcoord0 : TEXCOORD0;
};

STRATEGIC_VERTEX StrategicVS(
    float4 position : POSITION0,
    float2 texcoord0 : TEXCOORD0,
    float2 texcoord1 : TEXCOORD1
)
{
    STRATEGIC_VERTEX vertex = (STRATEGIC_VERTEX)0;
    
    vertex.position = mul( float4( position.x, mapElevation, position.z, 1), mul( WorldToView, Projection));
    vertex.texcoord0 = texcoord0;
    
    return vertex;
}

float4 StrategicPS( STRATEGIC_VERTEX vertex,
					uniform bool alphaTestEnable, 
				    uniform int alphaFunc, 
				    uniform int alphaRef ) : COLOR0
{
    float3 color = tex2D( FrameSampler1, vertex.texcoord0).rgb;
    float4 overlay = tex2D( FrameSampler2, vertex.texcoord0).rgba;
    float  fog = 1 - tex2D( FrameSampler3, vertex.texcoord0).r;
    float  dissolve = tex2D( FrameSamplerWrap4, 8 * vertex.texcoord0).a;
    if ( 1 == useStrategicOverlay ) color = overlay.a * overlay.rgb + ( 1 - overlay.a ) * fog * color;
    
    float alpha = saturate( dissolve + DissolveOffset);
#ifdef DIRECT3D10
	if( alphaTestEnable )
		AlphaTestD3D10( alpha, alphaFunc, alphaRef );
#endif
    return  float4( fog * color, alpha );
}

float4 AddPS(
	float4 Pos	 : POSITION,
    float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR
{
    return tex2D(FrameSamplerLinear1, Tex1);
	// + tex2D(FrameSampler2, Tex2);
	//return tex2D(FrameSampler2, Tex2);
	//return tex2D(FrameSampler1, Tex1);
}



float4 BasisPS(
	float4 Pos	 : POSITION,
	float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR
{
    // x, y = normal   w, a = basis
    float4 raw = tex2D(FrameSampler1, Tex1) * 2 - 1;

    // x,y is actually xz
    // normal from the textures
    float3 screenNormal = raw.xyy;
	screenNormal.z = sqrt( 1 - screenNormal.x*screenNormal.x - screenNormal.y*screenNormal.y );
	// swizzle screen normal so y is up
	screenNormal.xzy = screenNormal.xyz;
    
    // normal from the heightmap
    float4 baseNormal;
    baseNormal.xz = raw.zw;
	baseNormal.y = sqrt( 2 - baseNormal.x*baseNormal.x - baseNormal.z*baseNormal.z );
    
	// construct our basis from the base normal (tangent and bitangent)
	float3 h = normalize( baseNormal + float3( 0, 1, 0 ) );
	float3 x_ = h.xxx * h.xyz;
	float3 z_ = h.zzz * h.xyz;
	float3 mterm = float3( -2, 2, -2 );
	float3 aterm = float3( 1, 0, 0 );
	float3 xaxis = x_.xyz * mterm + aterm.xyz;
	float3 yaxis = baseNormal;
	float3 zaxis = z_.xyz * mterm + aterm.zyx;

	// rotate normal to conform with base normal
	float4 normal;
	normal.x = dot( screenNormal.xyz, xaxis );
	normal.y = dot( screenNormal.xyz, yaxis );
	normal.z = dot( screenNormal.xyz, zaxis );
	normal.w = 0;

    // convert into 0..1 range	
	normal = (normal * float4(0.5, 0.5, 0.5, 0)) + float4(0.5, 0.5, 0.5, 0);
	return normal;
}


// the minimum amount of glow we can out.  This is because we use
// the very bottom of the alpha range for to tell us if we have water at this point
// anything above 0.01 means that there is no water.  We subtract out the 0.01 on
// the other end of the glow equation
float   MinimumGlow = 0.02;


// Copy the glowing stuff out of the frame buffer by multiplying
// it with the dest alpha channel.
float4 CopyGlowingPS(
	float4 Pos	 : POSITION,
    float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR
{
	float4 c =  tex2D(FrameSamplerLinear1, Tex1 );
	c.a =  saturate( (c.a-MinimumGlow) * GlowCopyScale  + GlowCopyAdd);
	c = c * c.a;                           
	return c;
}





// blur the source image horizontally
float4 BlurHorizontalPS(
	float4 Pos	 : POSITION,
    float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR
{
    float4 Color = float4(0,0,0,0);
	
	for ( int i = 0; i < 7; i++)
		Color += BlurWeight[i] * tex2D(FrameSamplerLinear1,Tex1+float2(BlurKernel[i]/framewidth,0));

    Color *= BlurScale;
    return Color;
}

// blur the source image vertically
float4 BlurVerticalPS(
	float4 Pos	 : POSITION,
    float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR
{
    float4 Color = float4(0,0,0,0);

	for ( int i = 0; i < 7; i++)
		Color += BlurWeight[i] * tex2D(FrameSamplerLinear1,Tex1+float2(0,BlurKernel[i]/frameheight));

    Color *= BlurScale;
    return Color;
}


// just output black opaqueness
float4 OpaquePS(
	float4 Pos	 : POSITION,
	float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR
{
	return float4( 1, 0, 0, 1 );
}

// output a clear alpha channel
float4 BlackPS(
	float4 Pos	 : POSITION,
	float2 Tex1  : TEXCOORD0,
    float2 Tex2  : TEXCOORD1
    ) : COLOR
{
    return float4(0,0,0,0);
}


/*

// blur the image horizontally
technique TBlurHorizontal
{
    pass P0
    {
		AlphaState( AlphaBlend_Disable )
        DepthState( Depth_Disable )
        RasterizerState( Rasterizer_Cull_None )

        VertexShader = FIXED_FUNC_BLOOM_VS;
        PixelShader = compile ps_2_0 BlurHorizontalPS();
    }
}


// blur the image verically
technique TBlurVertical
{
    pass P0
    {
		AlphaState( AlphaBlend_Disable )
        DepthState( Depth_Disable )
        RasterizerState( Rasterizer_Cull_None )

        VertexShader = FIXED_FUNC_BLOOM_VS;
        PixelShader = compile ps_2_0 BlurVerticalPS();
    }
}

// grab all of the stuff from the other texture that is glowing	 (which is defined
// as having something in dest alpha!)
technique TCopyGlowingStuff
{
    pass P0
    {
        AlphaState( AlphaBlend_Disable )
        DepthState( Depth_Disable )
        RasterizerState( Rasterizer_Cull_None )

        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 CopyGlowingPS();
    }
}


technique TFrame
{
    pass P0
    { 
        AlphaState( AlphaBlend_One_Zero )
        DepthState( Depth_Disable )
        RasterizerState( Rasterizer_Cull_None )

        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 FixedPS();
    }
}

technique TBackground
{
    pass P0
    {
		AlphaState( AlphaBlend_Disable_Write_RGB )
		DepthState( Depth_Disable )
		RasterizerState( Rasterizer_Cull_None )

#ifndef DIRECT3D10
        AlphaTestEnable = true;
		AlphaRef = 0x7F;
		AlphaFunc = Greater;
#endif

        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 BackgroundPS( true, d3d_Greater, 0x7F );
    }
}

technique TStrategic
{
    pass P0
    {
		AlphaState( AlphaBlend_Disable_Write_RGB )
        RasterizerState( Rasterizer_Cull_None )
		DepthState( Depth_Enable_Always_Write_None )

#ifndef DIRECT3D10
        AlphaTestEnable = true;
		AlphaRef = 0x7F;
		AlphaFunc = Greater;
#endif

        VertexShader = compile vs_1_1 StrategicVS();
        PixelShader = compile ps_2_0 StrategicPS( true, d3d_Greater, 0x7F );
    }
}

///
///
///
technique TPunchout
{
    pass P0
    {
		AlphaState( AlphaBlend_Disable_Write_A )
        RasterizerState( Rasterizer_Cull_None )
		DepthState( Depth_Enable_Greater_Write_None )
		
        VertexShader = FIXED_FUNC_VS;        
        PixelShader = compile ps_2_0 PunchoutPS();
    }
}

///
///
///
technique RangeMask
{
    pass P0
    {
	    ColorWriteEnable = 0x00;

		ZWriteEnable = false;
		ZEnable = false;
		ZFunc = less;
		
		StencilEnable = true;
		StencilWriteMask = 0xFF;
		StencilMask = 0x7F;
		StencilRef = 0x80;
		StencilFunc = notequal;
		StencilFail = keep;
		StencilZFail = keep;
		StencilPass = replace;
		
        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 RangePS(float4(0,0,0,0));
    }
}

technique RangeFill
{
    pass P0
    {
	    ColorWriteEnable = 0x07;

		AlphaBlendEnable = true;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
		
		ZWriteEnable = false;
		ZEnable = false;
		ZFunc = less;
		
		StencilEnable = true;
		StencilWriteMask = 0x00;
		StencilMask = 0x80;
		StencilRef = 0xFF;
		StencilFunc = equal;
		StencilFail = keep;
		StencilZFail = keep;
		StencilPass = keep;
		
        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 RangePS(float4(1,1,1,0.125));
    }
}

technique RangeBurn
{
    pass P0
    {
	    ColorWriteEnable = 0x0F;

		AlphaBlendEnable = true;
		SrcBlend = one;
		DestBlend = zero;
		
		ZWriteEnable = false;
		ZEnable = false;
		ZFunc = less;
		
		StencilEnable = true;
		StencilWriteMask = 0x00;
		StencilMask = 0x7F;
		StencilRef = 0x00;
		StencilFunc = notequal;
		StencilFail = keep;
		StencilZFail = keep;
		StencilPass = keep;
		
        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 RangePS(rangeColor);
    }
}

technique Vision
{
    pass P0
    {
	    ColorWriteEnable = 0x07;

		AlphaBlendEnable = true;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
		
		ZWriteEnable = false;
		ZEnable = false;
		ZFunc = less;
		
		StencilEnable = true;
		StencilWriteMask = 0x00;
		StencilMask = 0xFF;
		StencilRef = 0x00;
		StencilFunc = equal;
		StencilFail = keep;
		StencilZFail = keep;
		StencilPass = keep;
		
        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 VisionPS(0.33);
    }
}

technique Boundary
{
    pass P0
    {
	    ColorWriteEnable = 0x07;

		AlphaBlendEnable = true;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
		
		ZWriteEnable = false;
		ZEnable = false;
		ZFunc = less;
		
		StencilEnable = true;
		StencilWriteMask = 0x00;
		StencilMask = 0xFF;
		StencilRef = 0x00;
		StencilFunc = notequal;
		StencilFail = keep;
		StencilZFail = keep;
		StencilPass = keep;
		
        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 VisionPS(1.0);
    }
}

/// TSilhouette
///
/// Render a solid color everywhere there is a value of 0x03 in the stencil buffer.
/// Does not write to the stencil buffer.
technique TSilhouette
{
    pass P0
    {
		AlphaState( AlphaBlend_Disable_Write_RGB )
        RasterizerState( Rasterizer_Cull_None )
        DepthState( Depth_TSilhouette )
        
#ifndef DIRECT3D10
        AlphaTestEnable = false;
#endif

        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 SilhouettePS();
    }
}

technique TFrameAdd
{
    pass P0
    {
		AlphaState( AlphaBlend_One_One )
        RasterizerState( Rasterizer_Cull_None )
		DepthState( Depth_Disable )
		
        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 AddPS();
    }
}

technique TAdd
{
    pass P0
    {
		AlphaState( AlphaBlend_One_One )
        RasterizerState( Rasterizer_Cull_None )
		DepthState( Depth_Disable )
		
        VertexShader = FIXED_FUNC_VS;
        PixelShader = compile ps_2_0 FixedPS();
    }
}


technique TOpaque
{
	pass P0
	{
		AlphaState( AlphaBlend_One_Zero_Write_A )
        RasterizerState( Rasterizer_Cull_None )
		DepthState( Depth_Disable )

		VertexShader = FIXED_FUNC_VS ;
		PixelShader = compile ps_2_0 OpaquePS();
	}
}




technique TBlack
{
	pass P0
	{
        RasterizerState( Rasterizer_Cull_None )
		AlphaState( AlphaBlend_One_Zero )
		DepthState( Depth_Disable )

		VertexShader = FIXED_FUNC_VS ;
		PixelShader = compile ps_2_0 BlackPS();
	}
}
*/


technique TCreateBasis
{
	pass P0
	{
		AlphaState( AlphaBlend_Disable )
		DepthState( Depth_Disable )
		RasterizerState( Rasterizer_Cull_None )

		VertexShader = FIXED_FUNC_VS;
		PixelShader = compile ps_2_0 BasisPS();
	}
}

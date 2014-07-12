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

#define     FIDELITY_LOW    0x00
#define     FIDELITY_MEDIUM 0x01
#define     FIDELITY_HIGH   0x02

float3		ViewPosition;
float		WaterElevation;
float       Time;
texture		SkyMap;
texture		NormalMap0;
texture		NormalMap1;
texture		NormalMap2;
texture		NormalMap3;
texture		RefractionMap;
texture		ReflectionMap;
texture		FresnelLookup;
float4      ViewportScaleOffset;
float4      TerrainScale;
texture     WaterRamp;

float waveCrestThreshold = 1;
float3 waveCrestColor = float3( 1, 1, 1);

float4x4		WorldToView;
float4x4		Projection;
texture		UtilityTextureC;

samplerCUBE SkySampler = sampler_state
{
	Texture   = <SkyMap>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = WRAP;
	AddressV  = WRAP;
	AddressW  = WRAP;
};


sampler NormalSampler0 = sampler_state
{
	Texture   = <NormalMap0>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = WRAP;
	AddressV  = WRAP;
};
sampler NormalSampler1 = sampler_state
{
	Texture   = <NormalMap1>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = WRAP;
	AddressV  = WRAP;
};
sampler NormalSampler2 = sampler_state
{
	Texture   = <NormalMap2>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = WRAP;
	AddressV  = WRAP;
};
sampler NormalSampler3 = sampler_state
{
	Texture   = <NormalMap3>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = WRAP;
	AddressV  = WRAP;
};


sampler FresnelSampler = sampler_state
{
	Texture   = <FresnelLookup>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

sampler RefractionSampler = sampler_state
{
	Texture   = <RefractionMap>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};


sampler ReflectionSampler = sampler_state
{
	Texture   = <ReflectionMap>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

sampler2D UtilitySamplerC = sampler_state
{
	Texture   = (UtilityTextureC);
	MipFilter = ANISOTROPIC;
	MinFilter = ANISOTROPIC;
	MagFilter = ANISOTROPIC;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

sampler2D MaskSampler = sampler_state
{
	Texture = (UtilityTextureC);
	MipFilter = POINT;
	MinFilter = POINT;
	MagFilter = POINT;
	AddressU  = CLAMP;
	AddressV  = CLAMP;	
};

//
// surface water color
//
float3 waterColor = float3(0,0.7,1.5);
float3 waterColorLowFi = float3(0.7647,0.8784,0.9647);

// 
// surface water lerp amount
//
float2 waterLerp = 0.3;

//
// scale of the refraction
//
float refractionScale = 0.015;

//
// fresnel parameters
//
float fresnelBias = 0.1;
float fresnelPower = 1.5;


//
// reflection amount
// 
float unitreflectionAmount = 0.5;

//
// sky reflection amount
//
float skyreflectionAmount = 1.5;



//
// 3 repeat rate for 3 texture layers
//
float4  normalRepeatRate = float4(0.0009, 0.009, 0.05, 0.5);


//
// 3 vectors of normal movements
float2 normal1Movement = float2(0.5, -0.95);
float2 normal2Movement = float2(0.05, -0.095);
float2 normal3Movement = float2(0.01, 0.03);
float2 normal4Movement = float2(0.0005, 0.0009);
//float2 normal2Movement = float2(0.3, 0.9);
//float2 normal3Movement = float2(0.03, -0.09);


// sun parameters
float		SunShininess = 50;
float3		SunDirection = normalize(float3( 0.1 ,   -0.967, 0.253));
float3		SunColor = normalize(float3( 1.2, 0.7, 0.5 ));
float       sunReflectionAmount = 5;
float       SunGlow;

///
///
///

struct LOWFIDELITY_VERTEX
{
    float4 position         : POSITION0;
    float2 texcoord0        : TEXCOORD0;
    float3 viewDirection    : TEXCOORD1;
    float2 normal0          : TEXCOORD2;
    float2 normal1          : TEXCOORD3;
    float2 normal2          : TEXCOORD4;
    float2 normal3          : TEXCOORD5;
};

LOWFIDELITY_VERTEX LowFidelityVS(float4 position : POSITION,float2 texcoord0 : TEXCOORD0 )
{
    LOWFIDELITY_VERTEX vertex = (LOWFIDELITY_VERTEX)0;

	position.y = WaterElevation;
	vertex.position = mul(float4(position.xyz,1),mul(WorldToView,Projection));
    vertex.texcoord0 = texcoord0;

    vertex.viewDirection = position.xyz - ViewPosition;
        
    vertex.normal0 = ( position.xz + ( normal1Movement * Time )) * normalRepeatRate.x;
    vertex.normal1 = ( position.xz + ( normal2Movement * Time )) * normalRepeatRate.y;
    vertex.normal2 = ( position.xz + ( normal3Movement * Time )) * normalRepeatRate.z;
    vertex.normal3 = ( position.xz + ( normal4Movement * Time )) * normalRepeatRate.w;
    
	return vertex;
}

float4 LowFidelityPS0( LOWFIDELITY_VERTEX vertex) : COLOR
{
    float4 water = tex2D(UtilitySamplerC,vertex.texcoord0);
    float  alpha = clamp(water.g,0,0.3);
    return float4(waterColorLowFi,alpha);
}

float4 LowFidelityPS1( LOWFIDELITY_VERTEX vertex) : COLOR
{
    float4 water = tex2D(UtilitySamplerC,vertex.texcoord0);
	float  alpha = clamp(water.g,0,0.2);
	
    float w0 = tex2D(NormalSampler0,vertex.normal0).a;
    float w1 = tex2D(NormalSampler1,vertex.normal1).a;
    float w2 = tex2D(NormalSampler2,vertex.normal2).a;
    float w3 = tex2D(NormalSampler3,vertex.normal3).a;
    
    float waveCrest = saturate(( w0 + w1 + w2 + w3 ) - waveCrestThreshold);
    return float4(waveCrestColor,waveCrest);
}

/*
technique Water_LowFidelity
<
    string abstractTechnique = "TWater";
    int fidelity = FIDELITY_LOW;
>
{
    pass P0
    {
		AlphaBlendEnable = true;
		ColorWriteEnable = 0x07;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
        
		ZEnable = true;
		ZFunc = lessequal;
		ZWriteEnable = false;
        
		VertexShader = compile vs_1_1 LowFidelityVS();
		PixelShader = compile ps_2_0 LowFidelityPS0();
    }
    pass P1
    {
		AlphaBlendEnable = true;
		ColorWriteEnable = 0x07;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
        
		ZEnable = true;
		ZFunc = lessequal;
		ZWriteEnable = false;
        
		VertexShader = compile vs_1_1 LowFidelityVS();
		PixelShader = compile ps_2_0 LowFidelityPS1();
    }
}
*/

///
///
///
                                
struct VS_OUTPUT
{
	float4 mPos			: POSITION;
	float2 mTexUV		: TEXCOORD0;
	float2 mLayer0      : TEXCOORD1;
	float2 mLayer1      : TEXCOORD2;
	float2 mLayer2      : TEXCOORD3;
    float2 mLayer3      : TEXCOORD4;	
	float3 mViewVec     : TEXCOORD5;
	float4 mScreenPos	: TEXCOORD6;
	//float3 mLightVector	: TEXCOORD6;
};

VS_OUTPUT WaterVS(
#ifdef DIRECT3D10
// stricter shader linkages require that this match the input layout
float3 inPos : POSITION,
#else
float4 inPos : POSITION, 
#endif
	float2 inTexUV	: TEXCOORD0 )
{
	inPos.y = WaterElevation;
	VS_OUTPUT result;

	float4x4 wvp = mul( WorldToView, Projection );
	result.mPos = mul( float4(inPos.xyz,1), wvp );
	
	// output the map coordinate so we can sample the water texture
	result.mTexUV = inTexUV;
	// output the screen position so we can sample the reflection / mask
	result.mScreenPos = result.mPos; 

    // calculate the texture coordinates for all 3 layers of water
    result.mLayer0 = (inPos.xz + (normal1Movement * Time)) * normalRepeatRate.x;
    result.mLayer1 = (inPos.xz + (normal2Movement * Time)) * normalRepeatRate.y;
    result.mLayer2 = (inPos.xz + (normal3Movement * Time)) * normalRepeatRate.z;
    result.mLayer3 = (inPos.xz + (normal4Movement * Time)) * normalRepeatRate.w;
    
    // calculate the view vector
    result.mViewVec = inPos.xyz - ViewPosition;   
    
//    float3 SunPosition = float3(175, 100, 0);     
//    result.mLightVector = inPos.xyz - SunPosition;

	return result;
}

float4 HighFidelityPS( VS_OUTPUT inV, 
					   uniform bool alphaTestEnable, 
					   uniform int alphaFunc, 
					   uniform int alphaRef ) : COLOR
{
    //
    // calculate the depth of water at this pixel, we use this to decide
    // how to shade and it should become lesser as we get shallower
    // so that we don't have a sharp line
    //
    float4 waterTexture = tex2D( UtilitySamplerC, inV.mTexUV );
    float waterDepth =  waterTexture.g;
  
    //waterDepth *= 50;

//    if( waterDepth > 0 )
//        waterDepth = 1;

  //  return waterDepth;

	//return waterTexture.r;


    //
    // calculate the correct viewvector
    //
    float3 viewVector = normalize(inV.mViewVec);

    //
    // get perspective correct coordinate for sampling from the other textures
    //
    float OneOverW = 1.0 / inV.mScreenPos.w;
    inV.mScreenPos.xyz *= OneOverW;
    float2 screenPos = inV.mScreenPos.xy * ViewportScaleOffset.xy;
    screenPos += ViewportScaleOffset.zw;

    //
    // calculate the background pixel
    //
    float4 backGroundPixels = tex2D( RefractionSampler, screenPos );
    float mask = saturate(backGroundPixels.a * 255);

    //
    // calculate the normal we will be using for the water surface
    //
    float4 W0 = tex2D( NormalSampler0, inV.mLayer0 );
	float4 W1 = tex2D( NormalSampler1, inV.mLayer1 );
	float4 W2 = tex2D( NormalSampler2, inV.mLayer2 );
	float4 W3 = tex2D( NormalSampler3, inV.mLayer3 );

    float4 sum = W0 + W1 + W2 + W3;
    float waveCrest = saturate( sum.a - waveCrestThreshold );
    
    // average, scale, bias and normalize
    float3 N = 2.0 * sum.xyz - 4.0;
    
    // flatness
    N = normalize(N.xzy); 
    float3 up = float3(0,1,0);
    N = lerp(up, N, waterTexture.r);
        
    // 
    // calculate the reflection vector
    //
	float3 R = reflect( viewVector, N );

    //
    // calculate the sky reflection color
    //
	float4 skyReflection = texCUBE( SkySampler, R );

    //
    // get the correct coordinate for sampling refraction and reflection
    //
    float2 refractionPos = screenPos;
//    refractionPos *= ViewportScaleOffset.xy;
//    refractionPos += ViewportScaleOffset.zw;
    refractionPos -=  refractionScale * N.xz * OneOverW;

    //
    // calculate the refract pixel, corrected for fetching a non-refractable pixel
    //
    float4 refractedPixels = tex2D( RefractionSampler, refractionPos);
    // because the range of the alpha value that we use for the water is very small
    // we multiply by a large number and then saturate
    // this will also help in the case where we filter to an intermediate value
    refractedPixels.xyz = lerp(refractedPixels, backGroundPixels, saturate(refractedPixels.w * 255) ).xyz;


    // 
    // calculate the reflected value at this pixel
    //
	float4 reflectedPixels = tex2D( ReflectionSampler, refractionPos);


    //
    // calculate the fresnel term from a lookup texture
    //
    float fresnel;    
    float  NDotL = saturate( dot(-viewVector, N) );
	fresnel = tex2D( FresnelSampler, float2(waterDepth, NDotL ) ).r;


    //
	// figure out the sun reflection
	//
	// moved this to a texture and no speedup.. already texture bwidth bound I think
    float3 sunReflection = pow( saturate(dot(-R, SunDirection)), SunShininess) * SunColor;


    //
    // lerp the reflections together
    //
    reflectedPixels = lerp( skyReflection, reflectedPixels, saturate(unitreflectionAmount * reflectedPixels.w));

    //
    // we want to lerp in some of the water color based on depth, but
    // not totally on depth as it gets clamped
    //
    float waterLerp2 = clamp(waterDepth, waterLerp.x, waterLerp.y);

    //
    // lerp in the color
    //
    refractedPixels.xyz = lerp( refractedPixels.xyz, waterColor, waterLerp2);
   
    // implement the water depth into the reflection
    float depthReflectionAmount = 10;
    skyreflectionAmount *= saturate(waterDepth * depthReflectionAmount);
   
    //
    // lerp the reflection into the refraction   
    //        
    refractedPixels = lerp( refractedPixels, reflectedPixels, saturate(skyreflectionAmount * fresnel));

    //
    // add in the sky reflection
    //
    sunReflection = sunReflection * fresnel;
    refractedPixels.xyz +=  sunReflection;


    // Lerp in a wave crest
    refractedPixels.xyz = lerp( refractedPixels.xyz, waveCrestColor, ( 1 - waterTexture.a ) * waveCrest);

    //
    // return the pixels masked out by the water mask
    //
#if 1    
    // use alphablend, don't get any glow
    float4 returnPixels = refractedPixels;
    returnPixels.a = 1 - mask;
#ifdef DIRECT3D10
	if( alphaTestEnable )
		AlphaTestD3D10( waterDepth, alphaFunc, alphaRef );
#endif
    return returnPixels;
#else    
    // use lerp, do get glow
    refractedPixels.w = sunReflection.r * SunGlow;
    float4 returnPixels = lerp( refractedPixels, backGroundPixels, mask);
#ifdef DIRECT3D10
	if( alphaTestEnable )
		AlphaTestD3D10( returnPixels.a, alphaFunc, alphaRef );
#endif
    return returnPixels;    
#endif    
}

technique Water_HighFidelity
<
    string abstractTechnique = "TWater";
    int fidelity = FIDELITY_HIGH;
>
{
	pass P0
	{
	    AlphaState( AlphaBlend_Disable_Write_RGB )
		DepthState( Depth_Enable_LessEqual_Write_None )
		RasterizerState( Rasterizer_Cull_CW )
		
#ifndef DIRECT3D10
        AlphaTestEnable = true;
        AlphaRef = 0x00;
        AlphaFunc = NotEqual;
#endif

		VertexShader = compile vs_1_1 WaterVS();
		PixelShader = compile ps_2_0 HighFidelityPS( true, d3d_NotEqual, 0 );
	}
}

struct MASK_OUTPUT
{
	float4 mPos			: POSITION0;
	float2 mTexUV0		: TEXCOORD0;
};



MASK_OUTPUT WaterAlphaMaskVS(
#ifdef DIRECT3D10
// stricter shader linkages require that this match the input layout
float3 inPos : POSITION,
#else
float4 inPos : POSITION0, 
#endif
	float2 inTexUV0	: TEXCOORD0 )
{
	MASK_OUTPUT result = (MASK_OUTPUT) 0;

	float4x4 wvp = mul( WorldToView, Projection );
	result.mPos = mul( float4(inPos.xyz,1), wvp );

	// water properties coords
	result.mTexUV0 = inTexUV0;

	return result;
}


float4 WaterLayAlphaMaskPS( MASK_OUTPUT inV,
							uniform bool alphaTestEnable, 
						    uniform int alphaFunc, 
						    uniform int alphaRef ) : COLOR
{
	float4 output = tex2D( MaskSampler, inV.mTexUV0 );
#ifdef DIRECT3D10
	if( alphaTestEnable )
		//AlphaTestD3D10( output, alphaFunc, alphaRef );
		  AlphaTestD3D10( output.a, alphaFunc, alphaRef );  //Fix for implicit vector truncation.  This may be incorrect. J.B. (Duck_42)
#endif
    return float4(0,0,0,output.b);
}

technique TWaterLayAlphaMask
{
	pass P0
	{
		AlphaState( AlphaBlend_Disable_Write_A )
		DepthState( Depth_Enable_Less_Write_None )
		RasterizerState( Rasterizer_Cull_CW )
       
#ifndef DIRECT3D10
		AlphaTestEnable = true;
		AlphaFunc = Equal;
		AlphaRef = 0;
#endif

		VertexShader = compile vs_1_1 WaterAlphaMaskVS();
		PixelShader = compile ps_2_0 WaterLayAlphaMaskPS( true, d3d_Equal, 0 );
	}
}

/// Shoreline
///
///

struct SHORELINE_VERTEX
{
    float4 position : POSITION0;
};

SHORELINE_VERTEX ShorelineVS( float2 position : POSITION0)
{
    SHORELINE_VERTEX vertex = (SHORELINE_VERTEX)0;
    vertex.position = float4( position.x, WaterElevation, position.y, 1);
    vertex.position = mul( vertex.position, mul( WorldToView, Projection));
    return vertex;
}

float4 ShorelinePS( SHORELINE_VERTEX vertex, 
					uniform bool alphaTestEnable, 
					uniform int alphaFunc, 
					uniform int alphaRef ) : COLOR0
{
	float4 output = float4(0,0,0,0);
#ifdef DIRECT3D10
	if( alphaTestEnable )
		AlphaTestD3D10( output.a, alphaFunc, alphaRef );
#endif
    return output;
}

technique TShoreline
{
    pass P0
    {
		AlphaState( AlphaBlend_Disable_Write_A )
		DepthState( Depth_Enable_Less_Write_None )
		RasterizerState( Rasterizer_Cull_CCW )
        
#ifndef DIRECT3D10
		AlphaTestEnable = true;
		AlphaFunc = Equal;
		AlphaRef = 0;
#endif

        VertexShader = compile vs_1_1 ShorelineVS();
        PixelShader = compile ps_2_0 ShorelinePS( true, d3d_Equal, 0 );
    }
}
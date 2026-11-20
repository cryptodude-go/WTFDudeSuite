-- Shared native guide skin for utility windows, including live theme previews.
local _,HP=...
local D=HP.Native;local UI=D.UI
local S={frames={}};HP.SuiteSkin=S
function S:Attach(f,height)
 if f.suiteSkin then return end
 f.suiteSkin=true;f.look=UI.Window(f,'panel')
 local band=CreateFrame('Frame',nil,f);band:SetPoint('TOPLEFT');band:SetPoint('TOPRIGHT');band:SetHeight(height or 25)
 band.bg=UI.Shape(f,'row',UI.C.panelTitlebar,'BACKGROUND'):Place(band);f.suiteTitleBand=band
 f.suiteSeparator=UI.Separator(f,-(height or 25),6,6)
 self.frames[f]=true
end
function S:Apply(f,cfg)
 if not f then return end
 local alpha=cfg and cfg.followTheme==false and (cfg.opacity or 60)/100 or UI.Theme.Opacity()
 local signature=tostring(UI.Theme.Current().id)..':'..tostring(alpha)
 if f.suiteSkinSignature==signature then return end
 f.suiteSkinSignature=signature
 f.look:SetBgAlpha(alpha)
 local colors={label='secondary',brand='accent',category='accent',title='text',detail='secondary',time='text',caption='secondary',count='muted',modelNote='muted'}
 for key,token in pairs(colors)do if f[key]then UI.Color(f[key],UI.C[token])end end
 if f.accent then UI.Fill(f.accent,UI.C.line)end
end
function S:Refresh()
 for f in pairs(self.frames)do self:Apply(f,f.suiteConfig)end
end
UI.Theme.OnApply(function()S:Refresh()end)
local opacity=D.Panel.SetBackgroundAlpha
function D.Panel:SetBackgroundAlpha(...)
 local result=opacity(self,...);S:Refresh();return result
end

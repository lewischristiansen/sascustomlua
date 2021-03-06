TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Hull Repair"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "sc_hull_repair" ] = "EM"

if ( CLIENT ) then
    language.Add( "Tool_sc_hull_repair_name", "Hull Repair Creation Tool" )
    language.Add( "Tool_sc_hull_repair_desc", "Spawns A Hull Repair." )
    language.Add( "Tool_sc_hull_repair_0", "Primary: Create/Update Hull Repair" )
	language.Add( "sboxlimit_sc_hull_repair", "You've hit the Hull Repair limit!" )
	language.Add( "undone_sc_hull_repair", "Undone Hull Repair" )
end

if (SERVER) then
  CreateConVar('sbox_maxsc_hull_repair',99)
end

cleanup.Register( "sc_hull_repair" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "sc_hull_repair" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	--if (trace.Entity:GetClass() != "prop_physics") then
	if trace.Entity:GetClass() == "sc_hull_repair" then
		local ent =  trace.Entity
		ent:Setup(type,self:GetOwner())
		return true --Stop it from going on to stuff below and making new ent
	end

	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "sc_hull_repair") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_hull_repair" ) ) then return false end

	--local Ang = trace.Entity:GetAngles()
	--local Pos =	trace.Entity:GetPos()
	local Ang = trace.HitNormal:Angle() + Angle(90,0,0)
	local Pos = trace.HitPos + trace.HitNormal * 4
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = Make_sc_hull_repair( ply, Pos, Ang, type, trace)
	
	local phys = Core:GetPhysicsObject()
	if (phys:IsValid() and trace.Entity:IsValid() ) then
		local weld = constraint.Weld(Core, trace.Entity, 0, trace.PhysicsBone, 0)
		local nocollide = constraint.NoCollide(Core, trace.Entity, 0, trace.PhysicsBone)
	end

	undo.Create("sc_hull_repair")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_hull_repair", Core )

	return true
	
end


function TOOL:Think()

end

list.Add( "sc_hull_repair_Types", "Civilian Hull Repair" )
list.Add( "sc_hull_repair_Types", "Small Hull Repair" )
list.Add( "sc_hull_repair_Types", "Medium Hull Repair" )
list.Add( "sc_hull_repair_Types", "Large Hull Repair" )

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_hull_repair_name", Description = "#Tool_sc_hull_repair_desc" })
	
	local Options = list.Get( "sc_hull_repair_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { sc_hull_repair_sc_hull_repair = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_hull_repair_name", Height = "400", Options = RealOptions} )
end
	

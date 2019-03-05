package haxevm.typer;

import haxe.macro.Expr;
import haxe.macro.Type.MetaAccess;

class MetaAccessImpl
{
	public static function make(meta:Null<Metadata>):MetaAccess
	{
		return new MetaAccessImpl(meta != null ? meta : []);
	}

	var meta:Metadata;

	function new(meta:Metadata)
	{
		this.meta = meta;
	}

	public function get():Metadata
	{
		return meta.copy();
	}

	public function extract(name:String):Array<MetadataEntry>
	{
		return meta.filter(f -> f.name == name);
	}

	public function add(name:String, params:Array<Expr>, pos:Position):Void
	{
		meta.push({
			name: name,
			params: params,
			pos: pos,
		});
	}

	public function remove(name:String):Void
	{
		meta = meta.filter(f -> f.name != name);
	}

	public function has(name:String):Bool
	{
		for (m in meta)
		{
			if (m.name == name)
			{
				return true;
			}
		}

		return false;
	}
}

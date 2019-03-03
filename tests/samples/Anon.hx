class Anon
{
	public static function main()
	{
		var obj = { sub: { hello: "well hello" }, a: 12, b: -7.2, t: true, f: false };
		trace(obj.sub.hello);
		trace(obj.a + obj.b);
		trace(obj.a - obj.b);

		trace(obj.a);
		trace(-obj.a);

		trace(obj.a--);
		trace(obj.a);
		trace(--obj.a);
		trace(obj.a);

		trace(obj.a++);
		trace(obj.a);
		trace(++obj.a);
		trace(obj.a);

		trace(obj.a < 0);
		trace(obj.a <= 0);
		trace(obj.a > 0);
		trace(obj.a >= 0);
		trace(obj.a == 0);
		trace(obj.a != 0);
		trace(obj.a < obj.b);
		trace(obj.a <= obj.b);
		trace(obj.a > obj.b);
		trace(obj.a >= obj.b);
		trace(obj.a == obj.b);
		trace(obj.a != obj.b);

		trace(obj.a % 2);
		trace(obj.a % -2);
		trace(125 % obj.a);
		trace(125 % -obj.a);

		trace(obj.a * obj.b);
		trace(obj.a * -obj.b);
		trace(-obj.a * obj.b);
		trace(-obj.a * -obj.b);
		trace(obj.b * obj.a);
		trace((obj.a + 2) * (obj.b - 1));

		trace(obj.a / obj.b);
		trace(obj.a / -obj.b);
		trace(-obj.a / obj.b);
		trace(-obj.a / -obj.b);

		trace(obj.a - obj.b);
		trace(obj.a - -obj.b);
		trace(-obj.a - obj.b);
		trace(-obj.a - -obj.b);

		trace(obj.a + obj.b);
		trace(obj.a + -obj.b);
		trace(-obj.a + obj.b);
		trace(-obj.a + -obj.b);

		trace(obj.a << 2);
		trace(obj.a >> 2);
		trace(obj.a >>> 2);
		trace(obj.a & (obj.a + 1));
		trace(obj.a | (obj.a + 1));
		trace(obj.a ^ (obj.a + 1));
		trace(~obj.a);

		obj.a += 2;
		trace(obj.a);
		obj.a -= 1;
		trace(obj.a);
		obj.a *= 10;
		trace(obj.a);
		obj.b /= 5;
		trace(obj.b);

		trace(obj.t == obj.t);
		trace(obj.t == obj.f);
		trace(obj.t != obj.t);
		trace(obj.t != obj.f);

		trace(obj.t && true);
		trace(obj.t || true);
		trace(obj.f && true);
		trace(obj.f || true);
		trace(obj.t && false);
		trace(obj.t || false);
		trace(obj.f && false);
		trace(obj.f || false);
	}
}

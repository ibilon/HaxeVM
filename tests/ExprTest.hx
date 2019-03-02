class ExprTest extends Test
{
	public function testAnonSample()
	{
		compareFile("tests/samples/Anon.hx");
	}

	public function testArraysSample()
	{
		compareFile("tests/samples/Arrays.hx");
	}

	public function testForSample()
	{
		compareFile("tests/samples/For.hx");
	}

	public function testHelloWorldSample()
	{
		compareFile("tests/samples/HelloWorld.hx");
	}

	public function testLocalFunctionSample()
	{
		compareFile("tests/samples/LocalFunction.hx");
	}

	public function testMainSample()
	{
		compareFile("tests/samples/Main.hx");
	}

	public function testOperatorsSample()
	{
		compareFile("tests/samples/Operators.hx");
	}

	@Ignored //TODO rework switch
	public function testSwitchSample()
	{
		compareFile("tests/samples/Switch.hx");
	}

	public function testThrowSample()
	{
		compareFile("tests/samples/Throw.hx");
	}

	public function testWhileSample()
	{
		compareFile("tests/samples/While.hx");
	}
}

class MiscTest extends Test
{
	public function testConditionalCompilationSample()
	{
		compareFile("tests/samples/ConditionalCompilation.hx");
		compareFile("tests/samples/ConditionalCompilation.hx", ["test" => "1"]);
		compareFile("tests/samples/ConditionalCompilation.hx", ["other" => "1"]);
	}
}

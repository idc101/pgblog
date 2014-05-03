test( "titleToUrlPart test", function() {
  equal( titleToUrlPart(""), "", "empty string" );
  equal( titleToUrlPart("Hello"), "hello", "capital letters" );
  equal( titleToUrlPart("   hello    "), "hello", "double spaces" );
  equal( titleToUrlPart("this is a   test"), "this-is-a-test", "spaces to dashes" );
  equal( titleToUrlPart("isn't it"), "isnt-it", "removing single quotes" );
  equal( titleToUrlPart("test @#$% 1234"), "test-1234", "removing non alpha numeric characters" );
});
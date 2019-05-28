var should = require('chai').should();

it('Should be my first successful test', function() {
  let success = true;
  success.should.be.true;
});

it('Should be my first failing test', function() {
  let success = false;
  success.should.be.true;
});

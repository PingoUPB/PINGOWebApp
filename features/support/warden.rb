# http://stackoverflow.com/a/8713889/238931
Warden.test_mode!

include Warden::Test::Helpers

After { Warden.test_reset! }
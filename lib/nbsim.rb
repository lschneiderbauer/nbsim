require 'nbsim/database'
require 'nbsim/simulator'

begin
	require 'Qt4'
	require 'nbsim/visualizer_qt'
	require 'nbsim/main_qt'
rescue LoadError
	$hasnot_qt4 = true
end

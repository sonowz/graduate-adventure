module Tests.Components.Test exposing (tests)

import Test exposing (Test, describe)
import Tests.Components.TextBox


tests : Test
tests = 
  describe "Components"
    [ Tests.Components.TextBox.tests
    ]
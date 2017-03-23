require "test_helper"

if Features.proposals?

  class ProposalsTest < JsFeatureTest
    
    test "Support" do
      user = create(:user)
      proposal = create(:proposal)
  
      login_as(user)
  
      visit proposals_path
  
      assert_content "Iniciativas Ciudadanas"
      
      click_button "Apoyar propuesta"
      assert_content "¡Muchas gracias!"
  
      debugger
      visit proposal_path(id: proposal)
      assert_content "Ya has apoyado esta propuesta. ¡Muchas gracias!"
  
      # TODO Proposal.frozen?
    end
  
  end

end

class PageController < ApplicationController
  def count_votes
    @election = Election.find(params[:election_id])
    votes = 0
    votes = @election.votes.count if @election
    render layout: 'minimal', locals: { votes: votes }
    #render plain: "#{votes}"
  end

  def privacy_policy
  end

  def faq
  end

  def legal
  end

  def cookie_policy
  end

  def inscription_policy
  end

  def guarantees
  end
end

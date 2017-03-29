class OnlineVerificationsController < ApplicationController
  before_action :load_user, except: [:index]
  before_action :load_pending_users

  def show
    authorize! :show, :online_verifications
  end

  def search
    authorize! :seach, :online_verifications

    redirect_to online_verification_path(@user)
  end

  def accept
    authorize! :accept, :online_verifications

    @user.verify_online!(current_user)

    pick_next
  end

  def reject
    authorize! :reject, :online_verifications

    @user.update!(banned: true)

    pick_next
  end

  def report
    authorize! :report, :online_verifications

    OnlineVerifications::Report.create!(report_params)

    redirect_to online_verification_path(@user),
                notice: I18n.t("online_verifications.report.success")
  end

  def index
    authorize! :index, :online_verifications
  end

  private

  def pick_next
    if @pending_users.any?
      redirect_to online_verification_path(@pending_users.first)
    else
      redirect_to online_verifications_path,
                  notice: I18n.t("online_verifications.you_are_done")
    end
  end

  def current_index
    @current_index ||= @pending_users.index(@user)
  end

  def total_count
    @total_count ||= @pending_users.size
  end

  helper_method :current_index, :total_count

  def load_pending_users
    @pending_users = User.online_verification_pending
  end

  def load_user
    @user = User.find(params[:user_id])
  end

  def report_params
    params
      .require(:online_verifications_report)
      .permit(:verified_id, label_ids: [])
      .merge(verifier_id: current_user.id)
  end
end

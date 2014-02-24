class UsersController < ApplicationController
  include ObjectifyParams
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  def index
    @user = User.find(8177)
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.save
    redirect_to @user, notice: 'User was successfully created.'
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  def add_friend
    User.add_friend(params[:user_id], params[:friend_id])
    redirect_to users_path
  end

  def remove_friend
    user = User.find(params[:user_id])
    user.unfriend(params[:friend_id])
    redirect_to users_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name)
    end
end

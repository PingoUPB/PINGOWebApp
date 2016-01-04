# :nocov:
class Admin::UsersController < ApplicationController
  require 'csv'
  
  if defined?(NewRelic)
    newrelic_ignore
  end

  before_filter :authenticate_user!
  before_filter :require_admin

  # GET /admin/users
  # GET /admin/users.json
  def index
    @users = User.order_by([[:created_at, :desc]])
    if params[:all] != "true"
      @users = @users.limit(100)
    end
    start_date = (Date.today - 1.month)
    conditions = User.where(:created_at.gte => start_date.to_time.utc).selector
    registrations_mr = User.collection.group(:keyf => "function(doc) { d = new Date(doc.created_at); return {month: d.getMonth() + 1, day: d.getDate() }; }",
                    :initial => { :registrations => 0 },
                    :reduce => "function(doc,prev) { prev.registrations += +1; }",
                    :cond => conditions)

    # smthg like: select day(users.created_at) as d, month(users.created_at) as m, sum(*) from users where created_at > :x group by (d, m)

    @registrations = {}

    start_date.upto(Date.today) do |day|
      @registrations["#{day.day}.#{day.month}"] = 0
    end

    registrations_mr.each do |reg|
      @registrations["#{reg["day"].to_i}.#{reg["month"].to_i}"] = reg["registrations"].to_i
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {users: @users, registrations: @registrations } }
    end
  end

  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /admin/users/new
  # GET /admin/users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /admin/users/1/edit
  def edit
    @user = User.find(params[:id])
    puts @user.inspect
  end

  # POST /admin/users
  # POST /admin/users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.json
  def update
    @user = User.find(params[:id])

    # https://github.com/plataformatec/devise/wiki/How-To:-Manage-users-through-a-CRUD-interface
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    @user.admin = (params[:user][:admin] == "1")

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_path }
      format.json { head :ok }
    end
  end

  def voting_analytics
    respond_to do |format|
      format.csv do
        csv_string = CSV.generate do |csv|
          Vote.all.each do |v|
            csv << [v.time_left, v.duration, v.session_uri, v.voter_id]
          end
        end
        render text: csv_string.to_s
      end
    end
  end

end
# :nocov:
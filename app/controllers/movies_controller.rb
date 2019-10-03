class MoviesController < ApplicationController
  helper_method :hilight
  helper_method :chosen_rating?

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # part1: sort the list of movies based on parameter
    # @movies = Movie.order(params[:order])
    
    
    # part2: 
    # @all_ratings = ['G','PG','PG-13','R']
    # if params[:ratings].nil?
    #   @movies = Movie.order params[:order]
    # else
    #   # filter movies based on ratings
    #   array_ratings = params[:ratings].keys
    #   @chosen_ratings = array_ratings
    #   @movies = Movie.where(rating: array_ratings).order params[:order]
    
    # part3: Remember the sorting and filtering settings
    session[:ratings] = params[:ratings] unless params[:ratings].nil?
    session[:order] = params[:order] unless params[:order].nil?
    @all_ratings = ['G','PG','PG-13','R']
    
    # apply settings from session when the incoming URI doesn’t have params
    if ((params[:ratings].nil? && !session[:ratings].nil?) || (params[:order].nil? && !session[:order].nil?))
      redirect_to movies_path("ratings" => session[:ratings], "order" => session[:order])
    
    # when URI has params, the new settings should be remembered in the session.
    elsif (!params[:ratings].nil? || !params[:order].nil?)
      if (!params[:ratings].nil?)
        array_ratings = params[:ratings].keys
        return @movies = Movie.where(rating: array_ratings).order(session[:order])
      else
        return @movies = Movie.all.order(session[:order])
      end
      
    else
      return @movies = Movie.all
    end
  end
  
  # The selected checkboxes should appear checked when the list is redisplayed
  def chosen_rating?(rating)
    #chosen_ratings = params[:ratings]
    chosen_ratings = session[:ratings]
    return true if chosen_ratings.nil?
    chosen_ratings.include? rating
  end
  
  # change the column's background color 
  def hilight(column)
    #if(params[:order].to_s == column)
    if(session[:order].to_s == column)
      return 'hilite'
    else
      return nil
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end

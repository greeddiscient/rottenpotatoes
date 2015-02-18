class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index 
    sort_selection = params[:sort]

    if session.has_key?(:first)
      session[:first]=false
    else
      session[:first]=true
    end
    
    if session[:first]
      flash.keep
      @all_ratings = ['G','PG','PG-13', 'NC-17','R']
      b={'G' => 1,'PG' => 1,'PG-13' => 1, 'NC-17' =>1, 'R' =>1}
      redirect_to movies_path(:ratings => b) and return
    else


      if sort_selection=="title"
        @title_header="hilite"
      elsif sort_selection=="release_date"
        @release_date_header="hilite"
      end

      @all_ratings = ['G','PG','PG-13', 'NC-17','R']
      @chosen_ratings = params[:ratings] || session[:ratings] || {}

      if @chosen_ratings == {}
        @chosen_ratings = {'G' => 1,'PG' => 1,'PG-13' => 1, 'NC-17' =>1, 'R' =>1 }
      end

      if ! session[:ratings]
        session[:ratings]=@chosen_ratings
      elsif !(params[:sort]== "title" or params[:sort]== "release_date")
        session[:ratings]=params[:ratings]
      end
   
      if params[:sort]== "title" or params[:sort]== "release_date"
        @chosen_ratings=session[:ratings]
      end

      if params[:sort]
        a=params[:sort]
      elsif session[:sort]
        a=session[:sort]
      end
          
      
      if (params[:sort]!=session[:sort]) or (params[:ratings]!=session[:ratings])
        flash.keep
        session[:sort]=sort_selection
        session[:ratings]=@chosen_ratings
        redirect_to movies_path(:ratings => @chosen_ratings, :sort => a) and return
      end
    end

    if not session.has_key?(:oneDirect)
      session[:oneDirect]=true
    else
      session.delete(:oneDirect)
    end

    if session.has_key?(:oneDirect)
      flash.keep
      redirect_to movies_path(:ratings => @chosen_ratings, :sort=>sort_selection) and return
    end
    

    @movies = Movie.find_all_by_rating(@chosen_ratings.keys, :order => sort_selection)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
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

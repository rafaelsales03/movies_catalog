require 'rails_helper'

RSpec.describe "/:locale/movies", type: :request do
  let(:user) { create(:user) }
  let!(:movie) { create(:movie, user: user) }
  let(:valid_attributes) { attributes_for(:movie) }
  let(:invalid_attributes) { attributes_for(:movie, title: nil) }

  let(:default_locale) { { locale: I18n.default_locale } }

  describe "GET /index" do
    it "renders a successful response" do
      get movies_url(default_locale)
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get movie_url(movie, default_locale)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    context "when user is signed in" do
      before { sign_in user }
      it "renders a successful response" do
        get new_movie_url(default_locale)
        expect(response).to be_successful
      end
    end
    context "when user is not signed in" do
      it "redirects to the login page" do
        get new_movie_url(default_locale)
        expect(response).to redirect_to(new_user_session_url(default_locale))
      end
    end
  end

  describe "GET /edit" do
    context "when user is signed in and owns the movie" do
      before { sign_in user }
      it "renders a successful response" do
        get edit_movie_url(movie, default_locale)
        expect(response).to be_successful
      end
    end
    context "when user is signed in but does not own the movie" do
      let(:other_user) { create(:user) }
      let!(:other_movie) { create(:movie, user: other_user) }
      before { sign_in user }
      it "redirects to movies index" do
        get edit_movie_url(other_movie, default_locale)
        expect(response).to redirect_to(movies_url(default_locale))
        expect(flash[:alert]).to eq(I18n.t("flash.movies.not_found"))
      end
    end
    context "when user is not signed in" do
      it "redirects to the login page" do
        get edit_movie_url(movie, default_locale)
        expect(response).to redirect_to(new_user_session_url(default_locale))
      end
    end
  end

  describe "POST /create" do
    context "when user is signed in" do
      before { sign_in user }
      context "with valid parameters" do
        it "creates a new Movie" do
          expect {
            post movies_url(default_locale), params: { movie: valid_attributes }
          }.to change(Movie, :count).by(1)
        end
        it "redirects to the created movie" do
          post movies_url(default_locale), params: { movie: valid_attributes }
          expect(response).to redirect_to(movie_url(Movie.last, default_locale))
        end
        it "assigns the movie to the current user" do
           post movies_url(default_locale), params: { movie: valid_attributes }
           expect(Movie.last.user).to eq(user)
        end
      end
      context "with invalid parameters" do
        it "does not create a new Movie" do
          expect {
            post movies_url(default_locale), params: { movie: invalid_attributes }
          }.to change(Movie, :count).by(0)
        end
        it "returns an unprocessable_content status" do
          post movies_url(default_locale), params: { movie: invalid_attributes }
         expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
     context "when user is not signed in" do
       it "does not create a movie and redirects to login" do
         expect {
           post movies_url(default_locale), params: { movie: valid_attributes }
         }.to change(Movie, :count).by(0)
         expect(response).to redirect_to(new_user_session_url(default_locale))
       end
     end
  end

  describe "PATCH /update" do
     context "when user is signed in and owns the movie" do
        before { sign_in user }
        context "with valid parameters" do
          let(:new_attributes) { { title: "Updated Movie Title", year: movie.year + 1 } }
          it "updates the requested movie" do
            patch movie_url(movie, default_locale), params: { movie: new_attributes }
            movie.reload
            expect(movie.title).to eq("Updated Movie Title")
            expect(movie.year).to eq(new_attributes[:year])
          end
          it "redirects to the movie" do
            patch movie_url(movie, default_locale), params: { movie: new_attributes }
            movie.reload
            expect(response).to redirect_to(movie_url(movie, default_locale))
          end
        end
        context "with invalid parameters" do
          it "returns an unprocessable_content status" do
            patch movie_url(movie, default_locale), params: { movie: invalid_attributes }
            expect(response).to have_http_status(:unprocessable_content)
          end
        end
    end
    context "when user is signed in but does not own the movie" do
      let(:other_user) { create(:user) }
      let!(:other_movie) { create(:movie, user: other_user) }
      let(:new_attributes) { { title: "Attempted Update" } }
      before { sign_in user }
      it "does not update the movie and redirects" do
        original_title = other_movie.title
        patch movie_url(other_movie, default_locale), params: { movie: new_attributes }
        other_movie.reload
        expect(other_movie.title).to eq(original_title)
        expect(response).to redirect_to(movies_url(default_locale))
      end
    end
     context "when user is not signed in" do
       let(:new_attributes) { { title: "Attempted Update" } }
       it "does not update the movie and redirects to login" do
         original_title = movie.title
         patch movie_url(movie, default_locale), params: { movie: new_attributes }
         movie.reload
         expect(movie.title).to eq(original_title)
         expect(response).to redirect_to(new_user_session_url(default_locale))
       end
     end
  end

  describe "DELETE /destroy" do
    context "when user is signed in and owns the movie" do
      before { sign_in user }
      it "destroys the requested movie" do
        movie_to_delete = create(:movie, user: user)
        expect {
          delete movie_url(movie_to_delete, default_locale)
        }.to change(Movie, :count).by(-1)
      end
      it "redirects to the movies list" do
        delete movie_url(movie, default_locale)
        expect(response).to redirect_to(movies_url(default_locale))
      end
    end
    context "when user is signed in but does not own the movie" do
       let(:other_user) { create(:user) }
       let!(:other_movie) { create(:movie, user: other_user) }
       before { sign_in user }
       it "does not destroy the movie and redirects" do
         expect {
           delete movie_url(other_movie, default_locale)
         }.to change(Movie, :count).by(0)
         expect(response).to redirect_to(movies_url(default_locale))
       end
    end
     context "when user is not signed in" do
       it "does not destroy the movie and redirects to login" do
         expect {
           delete movie_url(movie, default_locale)
         }.to change(Movie, :count).by(0)
         expect(response).to redirect_to(new_user_session_url(default_locale))
       end
     end
  end
end

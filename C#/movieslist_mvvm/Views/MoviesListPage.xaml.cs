namespace MovieCatalog.Views;

public partial class MoviesListPage : ContentPage
{
	public MoviesListPage()
	{
		InitializeComponent();
	}

    private async void ListView_ItemTapped(object sender, ItemTappedEventArgs e)
    {
        await Navigation.PushAsync(new Views.MovieDetailPage());
    }
}
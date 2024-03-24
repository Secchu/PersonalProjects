using System.Collections.Generic;
using System.Collections.ObjectModel;
using Windows.UI;

namespace DatabindingSample
{
    public class ColorListLogic : ObservableObject
    {
        public ObservableCollection<ColorDescriptor> FavoriteColors { get; } =
        new ObservableCollection<ColorDescriptor>();

        public List<ColorDescriptor> LotsOfColors { get; private set; }

        private ColorDescriptor _selectedColor;

        private ColorDescriptor _selectedFavoriteColor;

        public ColorListLogic()
        {
            LotsOfColors = new List<ColorDescriptor>
            {
               new ColorDescriptor(Colors.Red, "red"),
               new ColorDescriptor(Colors.White, "white"),
               new ColorDescriptor(Colors.Green, "green"),
               new ColorDescriptor(Colors.Yellow, "yellow"),
               new ColorDescriptor(Colors.Blue, "blue"),
               new ColorDescriptor(Colors.Black, "black")
            };

            SelectedColor = LotsOfColors[0];
        }

        public ColorDescriptor SelectedColor
        {
            get => _selectedColor;
            set => Set(ref _selectedColor, value);
        }

        public void AddSelectedColorToFavorites()
        {
            FavoriteColors.Add(SelectedColor);
        }

        public ColorDescriptor SelectedFavoriteColor
        {
            get => _selectedFavoriteColor;
            set
            {
                Set(ref _selectedFavoriteColor, value);
                RaisePropertyChanged(nameof(IsRemoveFavoriteColorButtonVisible));
            }
        }

        public bool IsRemoveFavoriteColorButtonVisible => SelectedFavoriteColor != null;

        public void RemoveFavoriteColor()
        {
            FavoriteColors.Remove(SelectedFavoriteColor);
        }
    }
}

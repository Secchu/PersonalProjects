using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using Windows.UI.Xaml;

namespace DatabindingSample
{
    public class ObservableObject : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private bool _isNameNeeded = true;

        protected bool Set<T>(ref T field, T newValue, 
        [CallerMemberName] string propertyName = null)
        {
            if (EqualityComparer<T>.Default.Equals(field, newValue))
            {
                return false;
            }

            field = newValue;
            RaisePropertyChanged(propertyName);
            return true;
        }

        public bool IsNameNeeded
        {
            get { return _isNameNeeded; }
            set { Set(ref _isNameNeeded, value); }  // Just one line!
        }

        protected void RaisePropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public Visibility GetGreetingVisibility()
        {
            return IsNameNeeded ? Visibility.Collapsed : Visibility.Visible;
        }
    }
}

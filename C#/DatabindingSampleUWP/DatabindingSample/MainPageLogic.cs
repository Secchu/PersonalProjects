using System;
using Windows.UI.Xaml;

namespace DatabindingSample
{
    public class MainPageLogic : ObservableObject
    {
        private DispatcherTimer _timer;
        private string _userName;

        public MainPageLogic()
        {
            _timer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };

            _timer.Tick += (sender, o) => RaisePropertyChanged(nameof(CurrentTime));

            _timer.Start();
        }

        public string CurrentTime => DateTime.Now.ToLongTimeString();

        public void Submit()
        {
            if (string.IsNullOrEmpty(UserName))
            {
                return;
            }

            IsNameNeeded = false;
            RaisePropertyChanged(nameof(GetGreetingVisibility));
        }

        
        public string UserName
        {
            get { return _userName; }
            set
            {
                _userName = value;
                RaisePropertyChanged(nameof(IsSubmitAllowed));
            }
        }

        public bool IsSubmitAllowed => UserName?.Trim().Length > 2;

    }
}

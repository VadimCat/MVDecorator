using System;
using System.Collections.Generic;
using Ji2;
using Ji2.Context;
using Ji2.States;

namespace Client.States
{
    public class StateFactory : IStateFactory
    {
        private readonly DiContext context;
        
        public StateFactory(DiContext context)
        {
            this.context = context;
        }

        public Dictionary<Type, IExitableState> GetStates(StateMachine stateMachine)
        {
            var dict = new Dictionary<Type, IExitableState>();
            
            dict[typeof(InitialState)] = new InitialState(stateMachine,
                context.GetService<Ji2Core.Core.ScreenNavigation.ScreenNavigator>(),
                context.GetService<SceneLoader>());
            
            // dict[typeof(GameState)] = new GameState(context.GetService<LoadingPresenterFactory>());

            return dict;
        } 
    }
}
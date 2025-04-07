# Tutorial round
import random
from collections import deque
import statistics
from datamodel import OrderDepth, UserId, TradingState, Order

# Could look into microprice for stationary one, https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2970694

observation_period = 5
microstructure = {"observations": {}}

class Trader: 
    def run(self, state:TradingState): 
        result = {} 
        # Using staionary strat for both, too tired to implement stuff rn. 
        for ticker in state.order_depths:
            if ticker not in microstructure["observations"]:
                microstructure["observations"][ticker] = deque([])
            result[ticker] = self.stationary_strat(ticker, state, spread=1.3)
        traderData = "Tutorial 0" 
        conversions = 1
        return result, conversions, traderData

    def stationary_strat(self, ticker: str,  state:TradingState, spread: int):
        
        orders = []

        # Strategy wont work well for this ticker as it is trendy, better  not to trade than loss lol. 
        if ticker == "RAINFOREST_RESIN": 
            return orders
        
        # we trade around the weighted mid price and capture some defined spread, no stop loss lol. YOLO 
        order_depth: OrderDepth = state.order_depths[ticker]
        best_ask = best_ask_amount = best_bid = best_bid_amount = 0.0
        if len(order_depth.sell_orders) != 0:
            best_ask, best_ask_amount = list(order_depth.sell_orders.items())[0]
        if len(order_depth.buy_orders) != 0:
            best_bid, best_bid_amount = list(order_depth.buy_orders.items())[0]

        # normal mid price
        mid_price = (best_bid + best_ask) / 2 
        observations = microstructure["observations"][ticker]
        
        observations.append(mid_price)
        print(f"observations {observations}, observation period {observation_period}")

        # Need enough observations
        if len(observations) <= observation_period: 
            return orders
        else:
            observations.popleft()
            mid_price_weighted = statistics.mean(observations)

            # Our Postions
            position = 0
            if ticker in state.position:
                position = state.position[ticker]

            # Our Trades
            own_trades = []
            if ticker in state.own_trades:
                own_trades = state.own_trades[ticker]
        
            # Just buy low sell, high. capture defined spread
            if position == 0 or len(own_trades) == 0:
                print(f"Flat at Best bid: {best_bid}, Best ask: {best_ask}, mid_price: {mid_price_weighted}")
                if (mid_price_weighted - int(best_ask)) >= spread: 
                   orders.append(Order(ticker, best_ask, -best_ask_amount))
                if (int(best_bid) - mid_price_weighted) >= spread: 
                    orders.append(Order(ticker, best_bid, best_bid_amount))   
            else:
                curr_pos_price = own_trades[0].price
                # We are long, we need to sell to flatten. 
                if position > 0 and (curr_pos_price - int(best_bid)) >= spread:
                    print("Profit opportunity")  
                    orders.append(Order(ticker, best_bid, position))   
                # We are short, we need to buy to flatten. 
                if position < 0 and (int(best_ask) - curr_pos_price) >= spread:
                    print("Profit opportunity")  
                    orders.append(Order(ticker, best_bid, position))  
        print(f"Orders : {orders}")  
        return orders

    def drifting_strat(self, ticker: str, state:TradingState): 
        # maybe some trend following or mean reversion to some fair price might work
        return []
    
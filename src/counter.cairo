use starknet::ContractAddress;

#[starknet::interface]
trait ICounterContract<TContractState> {
  fn get_counter(self: @TContractState) -> u32;
  fn increase_counter(ref self: TContractState);
}

#[starknet::contract]
mod CounterContract {
  use openzeppelin::access::ownable::OwnableComponent::InternalTrait;
  use starknet::{ContractAddress, get_caller_address};
  use openzeppelin::access::ownable::OwnableComponent;

  component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

  #[abi(embed_v0)]
  impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

  #[storage]
  struct Storage {
    counter: u32,
    #[substorage(v0)]
    ownable: OwnableComponent::Storage,
  }

  #[event]
  #[derive(Drop, starknet::Event)]
  enum Event {
    OwnableEvent: OwnableComponent::Event
  }

  #[constructor]
  fn constructor(ref self: ContractState, initial_counter: u32, initial_owner: ContractAddress) {
    self.counter.write(initial_counter);
    self.ownable.initializer(initial_owner);
  }

  #[abi(embed_v0)]
  impl CounterCounterImpl of super::ICounterContract<ContractState> {
    fn get_counter(self: @ContractState) -> u32{
      self.counter.read()
    }

    fn increase_counter(ref self: ContractState) {
      self.ownable.assert_only_owner();
      let current_counter = self.counter.read();
      self.counter.write(current_counter + 1);
    }
  }

}
use starknet::ContractAddress;

#[starknet::interface]
trait IOwnable<TContractState>{
  fn owner(self: @TContractState) -> ContractAddress;
  fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::component]
pub mod OwnableComponent {
    use starknet::{ContractAddress, get_caller_address};
    use core::num::traits::Zero;
    
    #[storage]
    struct Storage {
        owner: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        OwnershipTransferred: OwnershipTransferred
    }
  
    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[embeddable_as(OwnableImpl)]
    impl Ownable<
        TContractState, +HasComponent<TContractState>
    > of super::IOwnable<ComponentState<TContractState>> {
        fn owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owner.read()
        }
    
    fn transfer_ownership(ref self: ComponentState<TContractState>, new_owner: ContractAddress){
      
      assert(!new_owner.is_zero(), 'Caller is the zero address');

      self.asser_only_owner();
    }
  }

  #[generate_trait]
    pub impl InternalImpl<TContractState, +HasComponent<TContractState>> of 
    InternalTrait<TContractState> {

    fn initializer(ref self: ComponentState<TContractState>, owner: 
        ContractAddress) {
      self._transfer_ownership(owner);
    }

    fn assert_only_owner(self: @ComponentState<TContractState>) {

      let owner: ContractAddress = self.owner.read();
      let caller = get_caller_address();
  
      assert(caller == owner, 'Caller is not the owner');
    }

    fn _transfer_ownership(ref self: ComponentState<TContractState>, new_owner: ContractAddress) {
      let previous_owner = self.owner.read();
      self.owner.write(new_owner);
      self
      .emit(
          OwnershipTransferred { previous_owner: previous_owner, new_owner: new_owner }
      );
    }
  }
}
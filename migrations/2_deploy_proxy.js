const Dogs = artifacts.require('Dogs');
const DogsUpdated = artifacts.require('DogsUpdated');
const Proxy = artifacts.require('Proxy');

module.exports = async function(deployer, network, accounts) {
  //we start by deploying our contracts and we do that by taking the source files we have imported at top and creating an instance of the contracts
  const dogs = await Dogs.new();
  //with the proxy contract we need to pass in the address (dogs contract) from the constructor so it deploys properly
  const proxy = await Proxy.new(dogs.address);

  //We need a way to call functions in the proxy contract and have them routed to Dogs contract.
  //We can't just call funcions in the proxy & expect them to be routed to Dogs contract. Even though we passed in address, truffle doesn't recognize it like functions
  //The way around this is create creates an instance of the already deployed Dogs conract (.at - means it already exists) but pointing to the proxy address...
  //In other words we are telling truffle.. "there is a dog contract located at this address"  then we point the proxy address.
  //Its almost like tricking Truffle into believing its a Dog contrat but it points to the Proxy Address....
  //and this is ok cause we know the proxy can handle all the calls the dog contract can handle.
  var proxyDog = await Dogs.at(proxy.address);
  //know that we set this up, when we refernce proxyDog it means we will interact with the proxy contract but we are allowed to send Dog functions
  await proxyDog.setNumberOfDogs(10);
  var nrOfDogs = await proxyDog.getNumberOfDogs();
  console.log("Before update: " + nrOfDogs.toNumber());
  //Keep in mid we are storing all our data in the proxy contract. Calling proxyDog allows us to do that...
  //meaning, if we were just calling dogs.getNumberOfDogs() it wll save to the Dogs contract.

  //Scripts for the new contract
  const dogsUpdated = await DogsUpdated.new();
  //we use proxy instead of proxyDog becuase remember truffle thinks proxyDog is an actual dog contact and upgrade won't exist there. It exists on the proxy only.
  proxy.upgrade(dogsUpdated.address);
  //Again, fool truffle into believing we can call function on DogsUpdated even though it routes to the proxy
  proxyDog = await DogsUpdated.at(proxy.address);
  //call the initalize function in DogsUpdated or we can not call functions on the new contract. We must iniatilze and set ourselves as the owner.
  proxyDog.initialize(accounts[0]);

  //now we want to check that the storage worked (our number should be 10) in our new contract proxyDog...
  nrOfDogs = await proxyDog.getNumberOfDogs();
  console.log("After update: " + nrOfDogs.toNumber());

  //Here we can set the number of the dogs through the proxy contract with our new Upgraded Functional contract (DogsUpdated)
  //Important- the setNumberOfDogs function in the DogsUpdated contains an onlyOwner modifier. The original Dogs.sol did not. When we call set number of dogs it will...
  //fail unless we do a couple things. Because remember when we call functions on the functional contract (DogsUpdated)...
  //we aren't using its storage. We are making calls via delegateCall on the functional contract but using the Proxy storage. Even modifiers apply to this.
  //So how do we ensure that when we make calls to the functional contract (DogsUpdated) it knows we are the owner of the Proxy Contract (since it uses Proxy storage)?
  //1.)Our proxy uses all storage vars, so we have the state var "address public owner" already. What we didn't do is pass owner = msg.sender in constructor. Thats #1
  //2.)#1 alone is not suffice. It is also common practice to "initialize" the state of the functional contract via delegate call using init.
  //For #2 we create "function initialize" in our DogsUpdated (funcitonal) contract which we only one run once via the constructor. See DogsUpdated.sol for more.
  //3.)Now that we have function initialize along with the constructor set properly in the DogsUpdated we'll need to go back/up in contract and call the function...
  //just after proxy.upgrade(dogsUpdated.address) we will call the initalize function.
  //Now that we have initalized DogsUpdated and set ourselves as the owner, we can call setNumberOfDogs without onlyOnwer modifier blocking us
  await proxyDog.setNumberOfDogs(30);

  //Check so that setNumberOfDogs worked with new func contract.
  nrOfDogs = await proxyDog.getNumberOfDogs();
  console.log("Update2 " + nrOfDogs.toNumber());
  }

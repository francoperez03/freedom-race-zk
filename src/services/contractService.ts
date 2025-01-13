import { getInitialTestAccountsWallets } from "@aztec/accounts/testing";
import { PXEFactory } from "../factories/PXEFactory";
import { FreedomRaceContractArtifact } from "../../contracts/src/artifacts/FreedomRace";
import { Contract } from "@aztec/aztec.js";

export const deployContract = async (): Promise<string> => {
  try {
    const pxe = await PXEFactory.getPXEInstance();
    const [aliceWallet, bobWallet, carloWallet] = await getInitialTestAccountsWallets(pxe);

    const aliceAddress = aliceWallet.getAddress();
    const bobAddress = bobWallet.getAddress();
    const carloAddress = carloWallet.getAddress();

    const token = await Contract.deploy(aliceWallet, FreedomRaceContractArtifact, [
      [aliceAddress, bobAddress, carloAddress],
    ])
      .send()
      .deployed();

    console.log(`Contract deployed at ${token.address.toString()}`);

    const addresses = { token: token.address.toString() };
    console.log("addresses", addresses);
    return token.address.toString();
  } catch (error) {
    console.error("Error deploying contract:", error);
    throw error;
  }
};

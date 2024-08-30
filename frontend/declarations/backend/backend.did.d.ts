import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Recipe {
  'id' : bigint,
  'upvotes' : bigint,
  'title' : string,
  'instructions' : string,
  'downvotes' : bigint,
  'ingredients' : Array<string>,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : Recipe } |
  { 'err' : string };
export type Result_2 = { 'ok' : bigint } |
  { 'err' : string };
export interface _SERVICE {
  'addRecipe' : ActorMethod<[string, Array<string>, string], Result_2>,
  'getAllRecipes' : ActorMethod<[], Array<Recipe>>,
  'getRecipe' : ActorMethod<[bigint], Result_1>,
  'updateRating' : ActorMethod<[bigint, boolean], Result>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

export const idlFactory = ({ IDL }) => {
  const Result_2 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Recipe = IDL.Record({
    'id' : IDL.Nat,
    'upvotes' : IDL.Int,
    'title' : IDL.Text,
    'instructions' : IDL.Text,
    'downvotes' : IDL.Int,
    'ingredients' : IDL.Vec(IDL.Text),
  });
  const Result_1 = IDL.Variant({ 'ok' : Recipe, 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'addRecipe' : IDL.Func(
        [IDL.Text, IDL.Vec(IDL.Text), IDL.Text],
        [Result_2],
        [],
      ),
    'getAllRecipes' : IDL.Func([], [IDL.Vec(Recipe)], ['query']),
    'getRecipe' : IDL.Func([IDL.Nat], [Result_1], ['query']),
    'updateRating' : IDL.Func([IDL.Nat, IDL.Bool], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };

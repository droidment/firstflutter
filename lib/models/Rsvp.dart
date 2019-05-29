import 'package:cloud_firestore/cloud_firestore.dart';

class RSVP {
  DocumentReference game;
  String playerName;
  String yesNoMaybe;
  int guestCount;
  RSVP(DocumentReference game, String playerName, String yesNoMaybe,
      [int guestCount = 0]) {
    this.game = game;
    this.playerName = playerName;
    this.yesNoMaybe = yesNoMaybe;
    this.guestCount = guestCount;
  }
  toMap() {
    return {
      "Game": game,
      "PlayerName": playerName,
      "YesNoMaybe": yesNoMaybe,
      "GuestCount": guestCount
    };
  }

  doRSVP(RSVP rsvpUser, DocumentSnapshot gameData) async {
    //If this user RSVP already exists for this Game, update the response,
    // If not add.
    Firestore fireStore = Firestore.instance;

    CollectionReference gamePlayerReference =
        fireStore.collection("GamePlayers");
    Query gamePlayerQuery = gamePlayerReference
        .where("PlayerName", isEqualTo: rsvpUser.playerName)
        .where("Game", isEqualTo: rsvpUser.game);

    // String sYesNoMayCount = rsvpUser.yesNoMaybe + "Count";
    int iYesCount = gameData.data["YesCount"];
    int iNoCount = gameData.data["NoCount"];
    int iMaybeCount = gameData.data["MaybeCount"];
    int iGuestCount = gameData.data["GuestCount"];
    bool bUserPreviouslyHasGuest = false;
    bool bUserHasGuestNow = false;
    int iWaitlistCount = gameData.data["WaitlistCount"];

    await gamePlayerQuery.getDocuments().then((results) {
      if (results.documents.isNotEmpty) {
        results.documents.forEach((player) {
          String dbYesNoSelection = player.data['YesNoMaybe'].toString();
          //If the player had a previous guest selection

          if (rsvpUser.yesNoMaybe != dbYesNoSelection) {
            // Continue only if user changed the selection

            int playerGuestCount = player.data["GuestCount"];
            if (playerGuestCount is int && playerGuestCount > 0) {
              bUserPreviouslyHasGuest = true;
            }
            if (rsvpUser.guestCount is int && rsvpUser.guestCount > -1) {
              iGuestCount = rsvpUser.guestCount;
              bUserHasGuestNow = true;
            }
            if (rsvpUser.yesNoMaybe == "Guest") {
              rsvpUser.yesNoMaybe = "Yes";

              if (bUserPreviouslyHasGuest) {
                iYesCount = iYesCount - playerGuestCount;
              } else {
                if (player.data["YesNoMaybe"] != "Yes")
                  iYesCount = iYesCount + 1;
              }
              if (bUserHasGuestNow) {
                iYesCount = iYesCount + iGuestCount;
                player.data['GuestCount'] = iGuestCount;
              }
              if (dbYesNoSelection == "No") {
                iNoCount = iNoCount - 1;
              } else if (dbYesNoSelection == "Maybe") {
                iMaybeCount = iMaybeCount - 1;
              }
            } else if (rsvpUser.yesNoMaybe == "Yes") {
              iYesCount = iYesCount + 1;
              // if (bUserHasGuestNow) {
              //   iYesCount = iYesCount + iGuestCount;
              //   player.data['GuestCount'] = iGuestCount;
              // }
              if (dbYesNoSelection == "No") {
                iNoCount = iNoCount - 1;
              } else {
                iMaybeCount = iMaybeCount - 1;
              }
            } else if (rsvpUser.yesNoMaybe == "No") {
              iNoCount = iNoCount + 1;
              player.data['GuestCount'] = 0;
              if (dbYesNoSelection == "Yes") {
                iYesCount = iYesCount - 1;
                if (bUserPreviouslyHasGuest) {
                  iYesCount = ((iYesCount - playerGuestCount) > 0)
                      ? (iYesCount - playerGuestCount)
                      : 0;
                }
              } else {
                iMaybeCount = iMaybeCount - 1;
              }
            } else if (rsvpUser.yesNoMaybe == "Maybe") {
              iMaybeCount = iMaybeCount + 1;
              player.data['GuestCount'] = 0;
              if (dbYesNoSelection == "Yes") {
                iYesCount = iYesCount - 1;
                if (bUserPreviouslyHasGuest) {
                  iYesCount = ((iYesCount - playerGuestCount) > 0)
                      ? (iYesCount - playerGuestCount)
                      : 0;
                }
              } else {
                iNoCount = iNoCount - 1;
              }
            }
            player.data['YesNoMaybe'] = rsvpUser.yesNoMaybe;
            player.reference.updateData(player.data).then((result) {
              gameData.reference.updateData({
                "YesCount": iYesCount,
                "NoCount": iNoCount,
                "MaybeCount": iMaybeCount,
                "GuestCount": iGuestCount
              });
            });
          }
        });
      } else {
        if (rsvpUser.yesNoMaybe == "Guest") {
          rsvpUser.yesNoMaybe = "Yes";
          iYesCount = iYesCount + 1 + rsvpUser.guestCount;
        } else if (rsvpUser.yesNoMaybe == "Yes") {
          iYesCount = iYesCount + 1;
        } else if (rsvpUser.yesNoMaybe == "No") {
          iNoCount = iNoCount + 1;
        } else if (rsvpUser.yesNoMaybe == "Maybe") {
          iMaybeCount = iMaybeCount + 1;
        }
        gamePlayerReference.add(rsvpUser.toMap()).then((result) {
          gameData.reference.updateData({
            "YesCount": iYesCount,
            "NoCount": iNoCount,
            "MaybeCount": iMaybeCount,
            "GuestCount": rsvpUser.guestCount
          });
        });
      }
    });
  }
}
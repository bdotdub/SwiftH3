import Ch3
import Foundation

extension String {

    func toH3Index() -> H3Index {
        let str = strdup(self)
        return stringToH3(str)
    }

}
